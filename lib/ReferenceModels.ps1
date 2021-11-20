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

