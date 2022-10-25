$resourceGroupName = 'azfuncpwsh-poc'
New-AzSubscriptionDeployment -Location eastus2 -TemplateFile .\main.bicep -resourceBase $resourceGroupName -WhatIf