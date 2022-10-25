param location string
param name string
param vnetId string
param privateLinkSubnetId string
param fileShareName string

var queueEPName = 'pep${name}queue'

resource storage 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: name
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Cool'
  }

  resource fileServices 'fileServices' = {
    name: 'default'

    resource fileShare 'shares' = {
      name: fileShareName
    }
  }

  resource queueServices 'queueServices' = {
    name: 'default'

    resource triggerQueue 'queues' = {
      name: 'js-queue-items'
    }

    resource archiveQueue 'queues' = {
      name: 'psfunc-message-archive'
    }
  }
}

module queueStorageEndpoint '../network/privateEndpoint.bicep' = if(!empty(privateLinkSubnetId)) {
  name: queueEPName
  params: {
    location: location
    groupId: 'queue.core'
    privateDnsZoneName: 'queueDnsZone'
    privateEndpointName: queueEPName
    privateLinkResourceId: storage.id
    subnetId: privateLinkSubnetId
    vnetId: vnetId
  }
}

output storageId string = storage.id
output name string = name

output queuePEOutputId string = queueStorageEndpoint.outputs.privateEndpointId
