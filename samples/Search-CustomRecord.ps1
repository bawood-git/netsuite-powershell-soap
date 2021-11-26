<# 
.SYNOPSIS
     Search example
.DESCRIPTION
     Fetch a set of records of custom record type. Pagination is built into Get-SearchResults.
.NOTES
     Author   : Benjamin Wood - bawood@live.com
     History  : 2021-11-23 Initial Design
#>
param(
    [parameter(Mandatory=$true)]
    $ConfigurationFile,
    [parameter(Mandatory=$true)]
    $CustomeRecordId
)

Import-Module ../modules/netsuite-soap.psm1

#Fetch objects for building SOAP requests
Import-NetSuiteWSDL -WebServiceURL "https://webservices.netsuite.com/wsdl/v2021_2_0/netsuite.wsdl"

try {
    #Create Search
    $RecordRef = New-RecordRef -Type ([Netsuite.RecordType]::customRecord) -InternalId $CustomeRecordId
    $Search = New-RecordSearch_Basic -RecordRef $RecordRef

    #Add extra filter to get active records  
    $Search.basic.isInactive = New-Object NetSuite.SearchBooleanField
    $Search.basic.isInactive.searchValue = $false
    $Search.basic.isInactive.searchValueSpecified = $true

    #Execute
    $Account = Get-NetSuiteAccount -Path $ConfigurationFile
    $Records = Get-SearchResults -Account $Account -Search $Search
    Write-Verbose -Verbose -Message "$($Records.Count) records found"

}catch{
    Write-Error -Verbose -Exception $_.Exception
}
