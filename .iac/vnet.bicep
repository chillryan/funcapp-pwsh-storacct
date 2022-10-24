@description('Location for all resources.')
param location string = resourceGroup().location

@description('The name of the function app that you wish to create.')
param vnetName string = uniqueString(resourceGroup().id)

@description('The name of the subnet to be created within the virtual network')
param subnetName string = 'default'

var vnetAddressPrfix = '10.0.0.0/16'
var subnetAddressPrefix = '10.0.0.0/24'

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: 'vnet-${vnetName}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrfix
      ]
    }
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  parent: vnet
  name: subnetName
  properties: {
    addressPrefix: subnetAddressPrefix
    privateEndpointNetworkPolicies: 'Disabled'
  }
}

output vnetName string = vnet.name
output subnetName string = subnet.name
