# Input bindings are passed in via param block.
param([string] $QueueItem, $TriggerMetadata)

# Write out the queue message and insertion time to the information log.
Write-Host "PowerShell queue trigger function processed work item: $QueueItem"
Write-Host "Queue item insertion time: $($TriggerMetadata.InsertionTime)"

Get-Module -Name Az -ListAvailable -All

# Create a context object using Azure AD credentials
# $ctx = $(Get-AzStorageAccount -ResourceGroupName rg-ryhill-azfuncpwsh-poc).Context
$ctx = New-AzStorageContext -StorageAccountName $env:StorageAccountName -UseConnectedAccount

# Queue operations
$queueName = "psfunc-message-archive"
$queue = Get-AzStorageQueue -Name $queueName -Context $ctx

# Create a new message using a constructor of the CloudQueueMessage class
$archiveMessage = [Microsoft.Azure.Storage.Queue.CloudQueueMessage]::new("Archiving message: $($QueueItem)", $false)
$queue.CloudQueue.AddMessageAsync($archiveMessage)