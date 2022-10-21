@description('Location for all resources.')
param location string = resourceGroup().location

@description('The name of the function app that you wish to create.')
param appName string = uniqueString(resourceGroup().id)

var functionAppName = 'func${appName}'
var storageAcountName = 'st${replace(appName,'-','')}'

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageAcountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Cool'
  }
}

resource hostingPlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: 'plan-${appName}-${location}'
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {}
}

resource azureFunction 'Microsoft.Web/sites@2020-12-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageaccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageaccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageaccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageaccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(appName)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'powershell'
        }
      ]
    }
  }
}

output storageAccountName string = storageaccount.name
output functionAppName string = azureFunction.name
