
function New-CustomRecordSearch_Basic {
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
    