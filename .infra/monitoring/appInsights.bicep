param location string = resourceGroup().location
param appInsightsName string = uniqueString(resourceGroup().id)
param logAnalyticsWorkspaceName string = 'log${uniqueString(resourceGroup().id)}-${guid(appInsightsName)}'

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    sku: {
      name: 'Free'
    }
  }
}

output AppInsightsId string = appInsights.id
output InstrumentationKey string = appInsights.properties.InstrumentationKey
