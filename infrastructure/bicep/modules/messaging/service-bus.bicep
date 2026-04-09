@description('Service Bus namespace name')
param namespaceName string

@description('Location')
param location string = resourceGroup().location

@description('SKU')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param sku string = 'Basic'

@description('Queues to create')
param queues array = []

@description('Tags')
param tags object = {}

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: namespaceName
  location: location
  tags: tags
  sku: {
    name: sku
  }
  properties: {
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
  }
}

resource serviceBusQueues 'Microsoft.ServiceBus/namespaces/queues@2022-10-01-preview' = [for queue in queues: {
  parent: serviceBusNamespace
  name: queue.name
  properties: {
    maxDeliveryCount: queue.maxDeliveryCount
    lockDuration: queue.lockDuration
    requiresDuplicateDetection: false
    requiresSession: false
    enablePartitioning: false
    deadLetteringOnMessageExpiration: queue.enableDeadLetteringOnMessageExpiration
  }
}]

output namespaceName string = serviceBusNamespace.name
output namespaceId string = serviceBusNamespace.id
