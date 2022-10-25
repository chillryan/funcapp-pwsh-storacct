param vnetId string
param privateEndpointName string
param groupId string
param zoneName string
param standardDomain string = 'windows.net'
param domain string = 'privatelink.${groupId}.core.${standardDomain}'

var zoneGroupName = 'dzg${groupId}'

resource dnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: domain
  location: 'global'
}

resource vnetLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: '${domain}/${uniqueString(vnetId)}'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnetId
    }
    registrationEnabled: false
  }
  dependsOn: [
    dnsZone
  ]
}

module dnsZoneGroup 'dnsZoneGroups.bicep' = {
  name: zoneGroupName
  dependsOn: [
    vnetLinks
  ]
  params: {
    groupId: groupId
    privateDnsZoneId: dnsZone.id
    privateEndpointName: privateEndpointName
    zoneName: zoneName
  }
}

output dnsZoneId string = dnsZone.id
output dnsZoneGroupId string = dnsZoneGroup.outputs.dnsZoneGroupId
output vnetLinksLink string = vnetLinks.id
