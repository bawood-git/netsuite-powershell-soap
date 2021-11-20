<# .SYNOPSIS
     Token based authentication for NetSuite SOAP operations 
.DESCRIPTION
     Utilizing TokenPassport with HMACSHA_256 hash and JSON config. 
     This assumes an Integration Account, Employee Record, Roles, and Access Tokens have been properly set up. 
.NOTES
     Author   : Benjamin Wood - bawood@live.com
     TODO     : A lot.
     History  : 2021-11-18 Initial design
     
#>

param (
    $WSDL,
    $ConfigurationFile
    
)


# Enforce TLS
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

#Import WSDL with custom namespace
Write-Verbose -Verbose -Message "Loading WSDL: $WSDL"
$WSP = New-WebServiceProxy -Uri $WSDL -Class "extensions" -Namespace "NetSuite"


#########################################
# Functions
#########################################

function Get-AccountConfig {
   
    $Account = Get-Content -Path $ConfigurationFile |
    ConvertFrom-Json

    return $Account
}


function Get-TokenPassport {
    
    $Account = Get-AccountConfig

    $AccountId = $Account.AccountId
    $ConsumerKey = $Account.ConsumerKey
    $ConsumerSecret = $Account.ConsumerSecret
    $TokenId = $Account.TokenId
    $TokenSecret = $Account.TokenSecret

    $Nonce = [System.Guid]::NewGuid().toString('N')

    $Timestamp = [long]([System.DateTime]::UtcNow.Subtract((New-Object System.DateTime(1970, 1, 1)))).TotalSeconds

    $BaseString = "$AccountId&$ConsumerKey&$TokenId&$Nonce&$Timestamp"
    $SecretKey = "$ConsumerSecret&$TokenSecret"

    $HashObj = New-Object System.Security.Cryptography.HMACSHA256 
    $HashObj.Key = [System.Text.Encoding]::ASCII.GetBytes($SecretKey)

    $Signature = $HashObj.ComputeHash([System.Text.Encoding]::ASCII.GetBytes($BaseString))

    $EncodedSignature = [System.Convert]::ToBase64String($Signature)

    $PassportSig = New-Object NetSuite.TokenPassportSignature
    $PassportSig.algorithm = "HMAC_SHA256"
    $PassportSig.Value = $EncodedSignature

    $Passport = New-Object NetSuite.TokenPassport 
    $Passport.account = $AccountId
    $Passport.consumerKey = $ConsumerKey
    $Passport.token = $TokenId
    $Passport.nonce = $Nonce
    $Passport.timestamp = $Timestamp
    $Passport.signature = $PassportSig

    return $Passport
}

function Get-NetSuiteService {
    Write-Verbose -Verbose -Message "Creating passport"
    $Service = New-Object NetSuite.NetSuiteService  
    $Service.tokenPassport = Get-TokenPassport

    #Have to reconfigure service URLS post 2012 version, else you will receive HTTP 410: Gone       
    Write-Verbose -Verbose -Message "Fetching URLs"
    [System.Uri] $OriginalURI = $Service.Url
    [NetSuite.DataCenterUrls]$URLs = $Service.getDataCenterUrls((Get-AccountConfig).AccountId.toLower()).dataCenterUrls
    [System.Uri] $DataCenterURI = $URLs.webservicesDomain + $OriginalURI.PathAndQuery

    $Service.Url = $DataCenterURI.ToString()

    return $Service
}
