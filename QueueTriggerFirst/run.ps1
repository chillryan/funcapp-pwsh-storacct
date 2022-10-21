# Input bindings are passed in via param block.
param([string] $QueueItem, $TriggerMetadata)

# Write out the queue message and insertion time to the information log.
Write-Host "PowerShell queue trigger function processed work item: $QueueItem"
Write-Host "Queue item insertion time: $($TriggerMetadata.InsertionTime)"


$queueName = "js-queue-items-archive"
$queueMessage = [Microsoft.Azure.Storage.Queue.CloudQueueMessage]::new("Archiving message: $($QueueItem)")

# Create a context object using Azure AD credentials
$ctx = New-AzStorageContext -StorageAccountName $env:StorageAccountName -UseConnectedAccount
Get-AzStorageQueue -Context $ctx | Select-Object Name
$queue = Get-AzStorageQueue -Name $queueName -Context $ctx
$queue.CloudQueue.AddMessageAsync($queueMessage)