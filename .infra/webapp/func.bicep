param subnetId string
param storageAccountName string
param location string = resourceGroup().location
param appName string = uniqueString(resourceGroup().id)
param contentShareName string = '${appName}-content'

@description('Specify the Azure Function hosting plan SKU')
@allowed([
  'Y1'
  'EP1'
  'EP2'
])
param functionAppPlanSku string = 'EP1'


var hostPlanNmae = 'plan-${appName}-${location}'
var functionAppName = 'func${appName}'
var appInsightsName = 'appi${appName}'

resource mi 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'id${appName}'
  location: location
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

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
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
          value: contentShareName
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

  resource planNetworkConfig 'networkConfig' = if(!(empty(subnetId))) {
    name: 'virtualNetwork'
    properties: {
      subnetResourceId: subnetId
      swiftSupported: true
    }
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

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' existing = {
  name: storageAccountName
}

output storageAccountName string = storageAccount.name
output functionAppName string = function.name
