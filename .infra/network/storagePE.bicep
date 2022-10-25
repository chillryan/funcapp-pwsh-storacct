param privateEndpointName string
param location string
param vnetId string
param subnetId string
param storageAccount string
param groupId string
param privateDnsZoneName string

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-03-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: storage.id
          groupIds: [
            groupId
          ]
        }
      }
    ]
  }
}

module dnsZone '../dns/dnsZone.bicep' = {
  name: privateDnsZoneName
  dependsOn: [
    privateEndpoint
  ]
  params: {
    groupId: groupId
    privateEndpointName: privateEndpointName
    vnetId: vnetId
    zoneName: storageAccount
  }
}

resource storage 'Microsoft.Storage/storageAccounts@2021-06-01' existing = {
  name: storageAccount
}

output privateEndpointId string = privateEndpoint.id
output dnsZoneId string = dnsZone.outputs.dnsZoneId
output dnsZoneGroupId string = dnsZone.outputs.dnsZoneGroupId
output vnetLinksId string = dnsZone.outputs.vnetLinksLink
