@description('App Service name')
param appName string

@description('Location')
param location string = resourceGroup().location

@description('App Service Plan ID')
param appServicePlanId string

@description('Runtime stack (DOTNETCORE|8.0, NODE|18-lts)')
param runtimeStack string

@description('App settings')
param appSettings array = []

@description('Enable managed identity')
param enableManagedIdentity bool = true

@description('Tags')
param tags object = {}

resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: appName
  location: location
  tags: tags
  identity: enableManagedIdentity ? {
    type: 'SystemAssigned'
  } : null
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: runtimeStack
      alwaysOn: false  // F1 doesn't support always-on
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      appSettings: appSettings
    }
  }
}

output appName string = webApp.name
output defaultHostName string = webApp.properties.defaultHostName
output principalId string = enableManagedIdentity ? webApp.identity.principalId : ''
