@description('App Service Plan name')
param planName string

@description('Location for the resource')
param location string = resourceGroup().location

@description('SKU for the plan')
@allowed([
  'F1'
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
  'P1v2'
  'P2v2'
  'P3v2'
])
param sku string = 'F1'

@description('OS type')
@allowed([
  'linux'
  'windows'
])
param kind string = 'linux'

@description('Reserved for Linux')
param reserved bool = true

@description('Tags')
param tags object = {}

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: planName
  location: location
  tags: tags
  sku: {
    name: sku
  }
  kind: kind
  properties: {
    reserved: reserved
  }
}

output planId string = appServicePlan.id
output planName string = appServicePlan.name
