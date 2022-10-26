param vnetId string
param privateEndpointName string
param groupId string
param dnsZoneName string

var zoneGroupName = 'dzg${groupId}'

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: dnsZoneName
  location: 'global'
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${dnsZoneName}/${uniqueString(vnetId)}'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnetId
    }
    registrationEnabled: false
  }
  dependsOn: [
    privateDnsZone
  ]
}

module dnsZoneGroup 'dnsZoneGroups.bicep' = {
  name: zoneGroupName
  dependsOn: [
    privateDnsZoneLink
  ]
  params: {
    groupId: groupId
    dnsZoneName: dnsZoneName
    privateDnsZoneId: privateDnsZone.id
    privateEndpointName: privateEndpointName
  }
}

output dnsZoneId string = privateDnsZone.id
output dnsZoneGroupId string = dnsZoneGroup.outputs.dnsZoneGroupId
output vnetLinksLink string = privateDnsZoneLink.id
