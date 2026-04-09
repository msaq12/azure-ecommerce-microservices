@description('Registry name')
@minLength(5)
@maxLength(50)
param registryName string

@description('Location')
param location string = resourceGroup().location

@description('SKU')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param sku string = 'Basic'

@description('Enable admin user')
param adminUserEnabled bool = false

@description('Tags')
param tags object = {}

resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: registryName
  location: location
  tags: tags
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: adminUserEnabled
    publicNetworkAccess: 'Enabled'
  }
}

output registryName string = acr.name
output loginServer string = acr.properties.loginServer
output registryId string = acr.id
