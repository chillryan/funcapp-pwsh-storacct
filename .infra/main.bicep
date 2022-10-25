targetScope = 'subscription'

param resourceGroupName string = 'azfuncpwshpoc'
param location string

resource newRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${resourceGroupName}'
  location: location
}

var appName = 'func${uniqueString(newRG.id)}'
var vnetName = 'vnet-${uniqueString(newRG.id)}'
var storageAccountName = replace('stor${uniqueString(newRG.id)}','-','')

module network 'network/vnet.bicep' = {
  scope: newRG
  name: vnetName
  params: {
   location: location
   vnetName: vnetName    
  }
}

module storage 'storage/storage.bicep' = {
  scope: newRG
  name: storageAccountName
  params: {
    fileShareName: '${appName}-contents'
    location: location
    name: storageAccountName
    privateLinkSubnetId: network.outputs.privateLinkSubnetId
    vnetId: network.outputs.vnetId
  }
}

module functionApp 'webapp/func.bicep' = {
  scope: newRG
  name: appName
  dependsOn: [
    storage
  ]
  params: {
    location: location
    storageAccountName: storageAccountName
    subnetId: network.outputs.paasSubNetId
  }
}
