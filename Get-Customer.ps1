<# .SYNOPSIS
     Get Customer Record 
.DESCRIPTION
     Example of service.get(recordRef) to fetch a customer based on internalId
.NOTES
     Author   : Benjamin Wood - bawood@live.com
#>

param(
    [parameter(Mandatory=$true)]
    $ConfigurationFile,
    [parameter(Mandatory=$true)]
    $CustomerId
)

Import-Module ./modules/netsuite-soap.psm1

#Fetch objects for building SOAP requests
Import-NetSuiteWSDL -WebServiceURL "https://webservices.netsuite.com/wsdl/v2021_2_0/netsuite.wsdl"

###########################
# GET RECORD
###########################

try {
    $RefCustomer = New-RecordRef -Type ([NetSuite.RecordType]::customer) -InternalId $CustomerId
    $Account = Get-NetSuiteAccount -Path $ConfigurationFile
    $Service = Get-NetSuiteService -Account $Account

    Write-Verbose -Verbose -Message "Executing record lookup"
    $ReadResponse = $Service.get($RefCustomer)

     if ($ReadResponse.status.isSuccess) {
        
        $ReadResponse.record
    }else{
        
        Write-Warning -Verbose -Message "$($ReadResponse.status.statusDetail.code): $($ReadResponse.status.statusDetail.message)"
    }

}catch{
    Write-Error -Exception $_.Exception -Message $_.Exception.Message
}
