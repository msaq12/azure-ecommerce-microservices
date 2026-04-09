@description('APIM service name')
param apimName string

@description('Location')
param location string = resourceGroup().location

@description('Publisher email')
param publisherEmail string

@description('Publisher name')
param publisherName string

@description('SKU')
@allowed([
  'Developer'
  'Basic'
  'Standard'
  'Premium'
])
param sku string = 'Developer'

@description('Tags')
param tags object = {}

resource apiManagement 'Microsoft.ApiManagement/service@2022-08-01' = {
  name: apimName
  location: location
  tags: tags
  sku: {
    name: sku
    capacity: 1
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
  }
}

output apimName string = apiManagement.name
output gatewayUrl string = apiManagement.properties.gatewayUrl
output apimId string = apiManagement.id
