using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Interact with query parameters or the body of the request.
$msg = $Request.Query.Message
if (-not $msg) {
    $msg = $Request.Body.Message
}

$body = "This HTTP triggered function executed successfully. Pass a message in the query string or in the request body for processing."

if ($msg) {
    $exec = Get-Date -Format "MM/dd @ HH:mm K"
    $ctx = New-AzStorageContext -StorageAccountName $env:StorageAccountName -UseConnectedAccount

    # Queue operations
    $queueName = "js-queue-items"
    $queue = Get-AzStorageQueue -Name $queueName -Context $ctx
    
    # Create a new message using a constructor of the CloudQueueMessage class
    $queuemessage = [Microsoft.Azure.Storage.Queue.CloudQueueMessage]::new("Adding $($msg) at $($exec)", $false)
    $queue.CloudQueue.AddMessageAsync($queuemessage)
    $body = "Message added to the queue: $msg.\n\nThis HTTP triggered function executed successfully."
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})
