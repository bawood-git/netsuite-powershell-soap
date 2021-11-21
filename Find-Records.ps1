<# .SYNOPSIS
     Get and Search examples
.DESCRIPTION
     Fetch a set of records of custom record type
.NOTES
     Author   : Benjamin Wood - bawood@live.com
     TODO     : A lot. Definately don't want to fetch the WSDL for each call. Have a startup script like this instead
     History  : 2021-11-20 Initial design
     
#>

param(
    [parameter(Mandatory=$true)]
    $ConfigurationFile,
    [parameter(Mandatory=$true)]
    $CustomeRecordId
)

###########################
# LIBRARIES
###########################

#Init SOAP TBA
. .\lib\TokenPassport.ps1 -ConfigurationFile $ConfigurationFile -WSDL https://webservices.netsuite.com/wsdl/v2021_2_0/netsuite.wsdl

# Helpers
. .\lib\ReferenceModels.ps1
. .\lib\SearchModels.ps1

###########################
# SEARCH RECORD
###########################

try {
    $RecordRef = New-RecordRef -Type ([Netsuite.RecordType]::customRecord) -InternalId $CustomeRecordId
    $Search = New-CustomRecordSearch_Basic -RecordRef $RecordRef

    $Service = Get-NetSuiteService
    Write-Verbose -Verbose -Message "Executing custom record search"
    $Result = $Service.search($Search)
    
     if ($Result.status.isSuccess) {

        $Result

    }else{

        Write-Warning -Verbose -Message "$($Result.status.statusDetail.code): $($Result.status.statusDetail.message)"
    }
    
}catch{

    Write-Error -Exception $_.Exception -Message $_.Exception.Message
}
