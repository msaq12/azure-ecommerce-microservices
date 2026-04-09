@description('Event Grid topic name')
param topicName string

@description('Location')
param location string = resourceGroup().location

@description('Tags')
param tags object = {}

resource eventGridTopic 'Microsoft.EventGrid/topics@2022-06-15' = {
  name: topicName
  location: location
  tags: tags
  properties: {
    inputSchema: 'EventGridSchema'
    publicNetworkAccess: 'Enabled'
  }
}

output topicName string = eventGridTopic.name
output topicEndpoint string = eventGridTopic.properties.endpoint
output topicId string = eventGridTopic.id
