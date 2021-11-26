
#Enforce TLS 1.2
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

#########################################
# Functions
#########################################

function Get-NetSuiteAccount {
    param (
        [parameter(Mandatory=$true)]
        $Path
    )
       
    $Account = Get-Content -Path $Path |
    ConvertFrom-Json
    return $Account
}

function Import-NetSuiteWSDL {
    param (
        [parameter(Mandatory=$true)]
        $WebServiceURL
    )

    #Import WSDL with custom namespace
    Write-Verbose -Verbose -Message "Loading WSDL: $WebServiceURL"
    New-WebServiceProxy -Uri $WebServiceURL -Class "extensions" -Namespace "NetSuite"
}

function Get-TokenPassport {
    param(
        [parameter(Mandatory=$true)]
        $Account
    )

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
    param(
        [parameter(Mandatory=$true)]
        $Account
    )

    $Service = New-Object NetSuite.NetSuiteService  
    $Service.tokenPassport = Get-TokenPassport -Account $Account

    #Have to reconfigure service URLS post 2012 version, else you will receive HTTP 410: Gone       
    [System.Uri] $OriginalURI = $Service.Url
    [NetSuite.DataCenterUrls]$URLs = $Service.getDataCenterUrls($Account.AccountId.toLower()).dataCenterUrls
    [System.Uri] $DataCenterURI = $URLs.webservicesDomain + $OriginalURI.PathAndQuery
    $Service.Url = $DataCenterURI.ToString()

    return $Service
}

function New-RecordRef {
    param (
        [parameter(Mandatory=$true)]
        $Type,              # Enum [NetSuite.RecordType] for options
        $InternalId = $null # For custom records
    )
        $RecordRef = New-Object NetSuite.RecordRef
        $RecordRef.type = $Type
        $RecordRef.typeSpecified = $true
        $RecordRef.internalId = $InternalId
        
    return $RecordRef
}


function New-RecordSearch_Basic {
    #Returned object can be modified with additional parameters
    param (
        [parameter(Mandatory=$true)]
        $RecordRef
    )

    $Search = New-Object NetSuite.CustomRecordSearch
    $Search.basic = New-Object NetSuite.CustomRecordSearchBasic
    $Search.basic.recType = New-Object NetSuite.RecordRef
    $Search.basic.recType = $RecordRef
    return $Search
}

function Get-SearchResults {
    param (
        $Account,
        $Search
    )

    # Container for SearchResult record lists
    $Records = @()

    #Create request
    $Service = Get-NetSuiteService -Account $Account

    #Execute request
    Write-Progress -Activity "Record Search" -Status "Fetching search results" -PercentComplete 0
    $SearchResult = $Service.search($Search)

    if ($SearchResult.status.isSuccess) {
    
        $Records += $SearchResult.recordList        

        #Pagination if needed
        if ($SearchResult.totalPages -gt 1) {

            $SearchId = $SearchResult.searchId
            $Page = 2
            $Pages = $SearchResult.totalPages

            Write-Progress -Activity "Record Search" -Status "Fetching search results" -PercentComplete ($Page/$Pages*100)
        
            while ($Page -le $Pages){
                Write-Progress -Activity "Record Search" -Status "Fetching search results" -PercentComplete ($Page/$Pages*100)
                $Service = Get-NetSuiteService -Account $Account
                $SearchResult = $Service.searchMoreWithId($SearchId,$Page)
                $Records += $SearchResult.recordList
                $Page ++
            }
        }
    }else{
        Write-Warning -Verbose -Message "$($SearchResult.status.statusDetail.code): $($SearchResult.status.statusDetail.message)"
    }
    Write-Progress -Activity "Search" -Status "Fetching search results" -Completed

    return $Records
}

Export-ModuleMember Import-NetSuiteWSDL
Export-ModuleMember Get-NetSuiteAccount
Export-ModuleMember Get-NetSuiteService
Export-ModuleMember New-RecordRef
Export-ModuleMember New-RecordSearch_Basic
Export-ModuleMember Get-SearchResults






