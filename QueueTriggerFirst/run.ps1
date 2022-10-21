# Input bindings are passed in via param block.
param([string] $QueueItem, $TriggerMetadata)

# Write out the queue message and insertion time to the information log.
Write-Host "PowerShell queue trigger function processed work item: $QueueItem"
Write-Host "Queue item insertion time: $($TriggerMetadata.InsertionTime)"

# Create a context object using Azure AD credentials
$ctx = New-AzStorageContext -Endpoint $env:StorageAccountEndpoint -UseConnectedAccount

Get-AzStorageContainer -Context $ctx
Write-Host