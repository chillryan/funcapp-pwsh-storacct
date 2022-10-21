targetScope = 'subscription'

@description('The name of the resource group that you wish to create')
param resourceBase string = 'azfuncpwshpoc'

@description('The location where the resources will be deployed')
param location string

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${resourceBase}'
  location: location
}

module func 'func.bicep' = {
  name: 'func'
  scope: resourceGroup(rg.name)
  params: {
    location: location
  }
}

output storageAccountName string = func.outputs.storageAccountName
output functionAppName string = func.outputs.functionAppName
