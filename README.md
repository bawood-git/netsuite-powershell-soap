# netsuite
NetSuite PowerShell SOAP Interop

The purpose of this project is to give some basic examples for making requests from PowerShell to NetSuite using SOAP. The goal is to create a base project with example functions for handling tasks like fetching a record, searching, and creating transactions.

# Samples:
Get-Customer - Get customer body fields by internalId
Find-Records - Search for custom records created by custom record type using internalId of the record type

# Directories:
/template/account.json
Use this as a form for getting the required authentication details. It is a high security risk to put tokens and secrets in a clear text file. You'll need to implement your own secure way to retrieve the configuration data.

/lib

Helpers will be placed in here for handling tasks like authentication and structuring objects

/TokenPassport.ps1

Generates token-based authentication (TBA) Passport object. A new signature is required for each service call, using nonce as a variant.

/ReferenceModels.ps1

Used for RecordRef schema objects and the like. Ref objects are often used as foreign keys, creating relationships between records.

/SearchModels.ps1

Used to create basic search structures. These can be initialized from base template and later modified for a specific use case, like adding additional filters.
        
