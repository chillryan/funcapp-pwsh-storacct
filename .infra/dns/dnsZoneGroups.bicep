param privateDnsZoneId string
param privateEndpointName string
param groupId string
param dnsZoneName string

resource dnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: '${privateEndpointName}/default'
  properties: {
    privateDnsZoneConfigs: [
      {      
        name: '${dnsZoneName}-${groupId}-core-windows-net'
        properties: {
          privateDnsZoneId: privateDnsZoneId          
        }
      }
    ]
  }
}

output dnsZoneGroupId string = dnsZoneGroup.id
