param privateDnsZoneId string
param privateEndpointName string
param groupId string
param zoneName string

resource DnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: '${privateEndpointName}/default'
  properties: {
    privateDnsZoneConfigs: [
      {      
        name: '${zoneName}-${groupId}-core-windows-net'
        properties: {
          privateDnsZoneId: privateDnsZoneId          
        }
      }
    ]
  }
}

output dnsZoneGroupId string = DnsZoneGroup.id
