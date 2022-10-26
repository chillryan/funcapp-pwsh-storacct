param privateEndpointName string
param location string
param vnetId string
param subnetId string
param groupId string
param privateLinkResourceId string
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
          privateLinkServiceId: privateLinkResourceId
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
    dnsZoneName: privateDnsZoneName
    groupId: groupId
    privateEndpointName: privateEndpointName
    vnetId: vnetId
  }
}

output privateEndpointId string = privateEndpoint.id
output dnsZoneId string = dnsZone.outputs.dnsZoneId
output dnsZoneGroupId string = dnsZone.outputs.dnsZoneGroupId
output vnetLinksId string = dnsZone.outputs.vnetLinksLink
