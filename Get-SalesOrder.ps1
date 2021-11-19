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
    $SalesOrderId
)

#Init SOAP TBA
. .\lib\TokenPassport.ps1 -ConfigurationFile C:\proc\conf\account.json -WSDL https://webservices.netsuite.com/wsdl/v2021_2_0/netsuite.wsdl

try {
    # MUST initialize service with each request.
    $Service = Get-NetSuiteService

    $RefSalesOrder = New-Object NetSuite.RecordRef
    $RefSalesOrder.internalId = $SalesOrderId
    $RefSalesOrder.type = [NetSuite.RecordType]::salesOrder
    $RefSalesOrder.typeSpecified = $true

    [NetSuite.ReadResponse]$Response = $Service.get($RefSalesOrder)

     if ($Response.status.isSuccess) {

        [ordered]@{internalId = $Response.record.internalId; Customer=$Response.record.entity.name}

    }else{

        Write-Warning -Verbose -Message "$($Response.status.statusDetail.code): $($Response.status.statusDetail.message)"
    }
}catch{
    Write-Error -Exception $_.Exception -Message $_.Exception.Message

}