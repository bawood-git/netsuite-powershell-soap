# netsuite-powershell-soap
NetSuite tooling for SOAP API using PowerShell

The purpose of this project is to give some basic examples for making requests from PowerShell to NetSuite using SOAP. The goal is to create a base project with example functions for handling tasks like fetching a record, searching, and creating transactions.

Note: Sanbox accounts have a modified accountId, so if your account is 12345, sanbox iterations would be 12345_SB1, 12345_SB2, etc.

# /samples
* Get-Customer - Get customer body fields by internalId
* Search-CustomRecord - Search for custom records by internalId of the record type

# /template
account.json
Use this as a form for getting the required authentication details. It is a high security risk to put tokens and secrets in a clear text file. You'll need to implement your own secure way to retrieve the configuration data.

# /modules
Use Import-Module \path\to\netsuite-soap.psm1 for helpers handling tasks like authentication and structuring objects. 
