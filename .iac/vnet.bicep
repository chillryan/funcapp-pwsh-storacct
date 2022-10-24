@description('Location for all resources.')
param location string = resourceGroup().location

@description('The name of the virtual network to be created.')
param vnetName string = uniqueString(resourceGroup().id)

@description('The name of the subnet to be created within the virtual network.')
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

  resource subnet 'subnets' = {
    name: subnetName
    properties: {
      addressPrefix: subnetAddressPrefix
      delegations: [
        {
          name: 'delegation'
          properties: {
            serviceName: 'Microsoft.Web/serverfarms'
          }
        }
      ]
      // https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview
      serviceEndpoints: [
        {
          service: 'Microsoft.Storage'
        }
      ]
    }
  }
}

output vnetName string = vnet.name
output subnetName string = vnet::subnet.name
