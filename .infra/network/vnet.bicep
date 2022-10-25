param location string = resourceGroup().location
param vnetName string = uniqueString(resourceGroup().id)
param vnetAddressPrfix string = '10.17.0.0/24'

var paasSubnetName = 'paas'
param paasSubnetAddressPrefix string = '10.17.0.0/27'

var privateLinkSubnetName = 'privatelink'
param privateLinkSubnetAddressSpace string = '10.17.0.32/28'

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrfix
      ]
    }
  }

  resource paasSubnet 'subnets' = {
    name: paasSubnetName
    properties: {
      addressPrefix: paasSubnetAddressPrefix
      privateEndpointNetworkPolicies: 'Enabled'
      privateLinkServiceNetworkPolicies: 'Enabled'
      delegations: [
        {
          name: 'webapp'
          properties: {
            serviceName: 'Microsoft.Web/serverFarms'
          }
        }
      ]
    }
  }

  resource privateLinkSubnet 'subnets' = {
    name: privateLinkSubnetName
    properties: {
      addressPrefix: privateLinkSubnetAddressSpace
      privateEndpointNetworkPolicies: 'Disabled'
      privateLinkServiceNetworkPolicies: 'Enabled'
    }
  }
}

output vnetId string = vnet.id
output paasSubNetId string = vnet::paasSubnet.id
output privateLinkSubnetId string = vnet::privateLinkSubnet.id
