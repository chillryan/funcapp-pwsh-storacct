@description('Location for all resources.')
param location string = resourceGroup().location

@description('The name of the function app that you wish to create.')
param appName string = uniqueString(resourceGroup().id)

@description('Specify the Azure Function hosting plan SKU')
@allowed([
  'Y1'
  'EP1'
  'EP2'
])
param functionAppPlanSku string = 'EP1'

@description('The name of the vnet the function app will be integrated to')
param vnetName string

var hostPlanNmae = 'plan-${appName}-${location}'
var functionAppName = 'func${appName}'
var storageAcountName = 'st${replace(appName, '-', '')}'
var appInsightsName = 'appi${appName}'

resource mi 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'id${appName}'
  location: location
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
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

resource queue 'Microsoft.Storage/storageAccounts/queueServices/queues@2021-02-01' = {
  name: '${storageAccount.name}/default/js-queue-items'
}

resource hostingPlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: hostPlanNmae
  location: location
  sku: {
    name: functionAppPlanSku
    tier: functionAppPlanSku == 'Y1' ? 'Dynamic' : 'ElasticPremium'
  }
  properties: {}
}

resource function 'Microsoft.Web/sites@2020-12-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned, UserAssigned'
    userAssignedIdentities: {
      '${mi.id}': {
      }
    }
  }
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'StorageAccountName'
          value: storageAccount.name
        }
        {
          name: 'ResourceGroupName'
          value: resourceGroup().name
        }
        {
          name: 'ClientId'
          value: mi.properties.clientId
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(appName)
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: 'InstrumentationKey=${appInsights.properties.InstrumentationKey}'
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
      powerShellVersion: '7.2'
      vnetRouteAllEnabled: true
    }
  }

  resource networkConfig 'networkConfig' = {
    name: 'virtualNetwork'
    properties: {
      subnetResourceId: vnet.properties.subnets[0].id
      swiftSupported: true
    }
  }

  dependsOn: [
    vnet
  ]
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

// See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#contributor'
var roleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', '974c5e8b-45b9-4653-ba55-5f855dd0fb88')
var roleAssignmentName = guid(resourceGroup().id, mi.name, roleDefinitionId)

resource miRoleAssign 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storageAccount
  name: roleAssignmentName
  properties: {
    principalId: mi.properties.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: roleDefinitionId
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' existing = {
  name: vnetName
}

output storageAccountName string = storageAccount.name
output functionAppName string = function.name
