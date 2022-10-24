targetScope = 'subscription'

@description('The name of the resource group that you wish to create')
param resourceBase string = 'azfuncpwshpoc'

@description('The location where the resources will be deployed')
param location string

@description('Specify the Azure Function hosting plan SKU')
@allowed([
  'Y1'
  'EP1'
  'EP2'
])
param planSku string = 'EP1'

resource newRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${resourceBase}'
  location: location
}

module vnetModule 'vnet.bicep' = {
  name: '${deployment().name}-deploy-vnet'
  scope: newRG
  params: {
    location: location
  }
}

module funcModule 'func.bicep' = {
  name: '${deployment().name}-deploy-function'
  scope: newRG
  params: {
    location: location
    functionAppPlanSku: planSku
    vnetName: vnetModule.outputs.vnetName
  }
  dependsOn: [
    vnetModule
  ]
}

output storageAccountName string = funcModule.outputs.storageAccountName
output functionAppName string = funcModule.outputs.functionAppName
