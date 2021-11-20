<# .SYNOPSIS
     Fetch a SalesOrder
.DESCRIPTION
     Fetch a record where the internalId is known
.NOTES
     Author   : Benjamin Wood - bawood@live.com
     TODO     : A lot. Definately don't want to fetch the WSDL for each call. Have a startup script like this instead
     History  : 2021-11-18 Initial design
     
#>

param(
    [parameter(Mandatory=$true)]
    $ConfigurationFile,
    [parameter(Mandatory=$true)]
    $CustomerId
)
###########################
# LIBRARIES
###########################

#Init SOAP TBA
. .\lib\TokenPassport.ps1 -ConfigurationFile $ConfigurationFile -WSDL https://webservices.netsuite.com/wsdl/v2021_2_0/netsuite.wsdl

# Helpers
. .\lib\ReferenceModels.ps1


###########################
# GET RECORD
###########################

try {
    # Note: Get returns [NetSuite.ReadResponse] object. Other verbs return different objects 
    $RefCustomer = New-RecordRef -Type ([NetSuite.RecordType]::customer) -InternalId $CustomerId
    $Service = Get-NetSuiteService

    Write-Verbose -Verbose -Message "Executing record lookup"
    $Response = $Service.get($RefCustomer)

     if ($Response.status.isSuccess) {

        $Response.record

    }else{

        Write-Warning -Verbose -Message "$($Response.status.statusDetail.code): $($Response.status.statusDetail.message)"
    }

}catch{

    Write-Error -Exception $_.Exception -Message $_.Exception.Message

}
