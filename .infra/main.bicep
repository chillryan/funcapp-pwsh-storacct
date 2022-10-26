targetScope = 'subscription'

param resourceGroupName string = 'azfuncpwshpoc'
param location string
param createPrivateEndpoint bool = false

resource newRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${resourceGroupName}'
  location: location
}

var appName = 'func${uniqueString(newRG.id)}'
var vnetName = 'vnet-${uniqueString(newRG.id)}'
var storageAccountName = 'stor${uniqueString(newRG.id)}'

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
  name: replace(storageAccountName,'-','')
  dependsOn: [
    network
  ]
  params: {
    fileShareName: '${appName}-contents'
    location: location
    name: storageAccountName
    privateLinkSubnetId: createPrivateEndpoint ? network.outputs.privateLinkSubnetId : ''
    vnetId: network.outputs.vnetId
  }
}

module functionApp 'webapp/function.bicep' = {
  scope: newRG
  name: appName
  dependsOn: [
    storage
  ]
  params: {
    location: location
    appName: appName
    storageAccountName: storageAccountName
    subnetId: network.outputs.paasSubNetId
    privateLinkSubnetId: createPrivateEndpoint ? network.outputs.privateLinkSubnetId : ''
    vnetId: network.outputs.vnetId
  }
}

output virtualNetworkId string = network.outputs.vnetId
output privateLinkSubnetId string = network.outputs.privateLinkSubnetId
output storageId string = storage.outputs.storageId
