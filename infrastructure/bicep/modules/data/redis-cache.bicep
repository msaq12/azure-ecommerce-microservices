@description('Redis Cache name')
param cacheName string

@description('Location')
param location string = resourceGroup().location

@description('SKU')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param sku string = 'Basic'

@description('SKU family (C or P)')
@allowed([
  'C'
  'P'
])
param family string = 'C'

@description('SKU capacity (0-6 for C, 1-5 for P)')
@minValue(0)
@maxValue(6)
param capacity int = 0

@description('Tags')
param tags object = {}

resource redisCache 'Microsoft.Cache/redis@2023-04-01' = {
  name: cacheName
  location: location
  tags: tags
  properties: {
    sku: {
      name: sku
      family: family
      capacity: capacity
    }
    enableNonSslPort: false
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    redisConfiguration: {
      'maxmemory-policy': 'allkeys-lru'
    }
  }
}

output cacheName string = redisCache.name
output hostName string = redisCache.properties.hostName
output sslPort int = redisCache.properties.sslPort
output cacheId string = redisCache.id
