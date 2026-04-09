targetScope = 'resourceGroup'

// ============================================================================
// PARAMETERS
// ============================================================================

@description('Environment name')
@allowed(['dev', 'staging', 'prod'])
param environment string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Unique suffix for global resources')
param uniqueSuffix string = uniqueString(resourceGroup().id)

@description('Tags for all resources')
param tags object = {
  Environment: environment
  Project: 'FurnitureDropship'
  ManagedBy: 'Bicep'
}

// ============================================================================
// STORAGE MODULE
// ============================================================================

module storage 'modules/storage/storage-account.bicep' = {
  name: 'storage-deployment'
  params: {
    storageAccountName: 'stfurnit${uniqueSuffix}'
    location: location
    tags: tags
    sku: environment == 'prod' ? 'Standard_GRS' : 'Standard_LRS'
    containers: [
      'product-images'
      'product-videos'
      'documents'
      'uploads'
      'exports'
      'backups'
    ]
  }
}

// ============================================================================
// DATA MODULES
// ============================================================================

module sqlServer 'modules/data/sql-server.bicep' = {
  name: 'sql-server-deployment'
  params: {
    serverName: 'sql-furniture-${environment}-${uniqueSuffix}'
    location: location
    administratorLogin: 'sqladmin'
    administratorPassword: 'P@ssw0rd123!'
    tags: tags
  }
}

module sqlDatabase 'modules/data/sql-database.bicep' = {
  name: 'sql-database-deployment'
  params: {
    serverName: sqlServer.outputs.serverName
    databaseName: 'OrdersDB'
    location: location
    sku: environment == 'prod' ? 'S1' : 'Basic'
    tags: tags
  }
}

module cosmosDb 'modules/data/cosmos-account.bicep' = {
  name: 'cosmos-deployment'
  params: {
    accountName: 'cosmos-product-${environment}-${uniqueSuffix}'
    location: location
    databaseName: 'ProductsDB'
    containerName: 'Products'
    partitionKeyPath: '/categoryId'
    throughput: environment == 'prod' ? 1000 : 400
    tags: tags
  }
}

module redis 'modules/data/redis-cache.bicep' = {
  name: 'redis-deployment'
  params: {
    cacheName: 'redis-furniture-${environment}-${uniqueSuffix}'
    location: location
    sku: environment == 'prod' ? 'Standard' : 'Basic'
    family: 'C'
    capacity: environment == 'prod' ? 1 : 0
    tags: tags
  }
}

// ============================================================================
// SECURITY MODULE
// ============================================================================

module keyVault 'modules/security/key-vault.bicep' = {
  name: 'keyvault-deployment'
  params: {
    vaultName: 'kv-furn-${environment}-${take(uniqueSuffix, 8)}'
    location: location
    enablePurgeProtection: environment == 'prod' ? true : false
    tags: tags
  }
}

// ============================================================================
// MONITORING MODULES
// ============================================================================

module logAnalytics 'modules/monitoring/log-analytics.bicep' = {
  name: 'loganalytics-deployment'
  params: {
    workspaceName: 'log-furniture-${environment}-${uniqueSuffix}'
    location: location
    retentionInDays: environment == 'prod' ? 90 : 30
    tags: tags
  }
}

module appInsights 'modules/monitoring/app-insights.bicep' = {
  name: 'appinsights-deployment'
  params: {
    appInsightsName: 'appinsights-furniture-${environment}-${uniqueSuffix}'
    location: location
    workspaceResourceId: logAnalytics.outputs.workspaceId
    tags: tags
  }
}

// ============================================================================
// COMPUTE MODULES
// ============================================================================

module appServicePlan 'modules/compute/app-service-plan.bicep' = {
  name: 'appserviceplan-deployment'
  params: {
    planName: 'plan-furniture-${environment}-${uniqueSuffix}'
    location: location
    sku: environment == 'prod' ? 'P1v2' : 'F1'
    kind: 'linux'
    tags: tags
  }
}

module productService 'modules/compute/app-service.bicep' = {
  name: 'productservice-deployment'
  params: {
    appName: 'app-product-service-${environment}-${uniqueSuffix}'
    location: location
    appServicePlanId: appServicePlan.outputs.planId
    runtimeStack: 'DOTNETCORE|10.0'
    appSettings: [
      {
        name: 'KeyVault__VaultUri'
        value: keyVault.outputs.vaultUri
      }
      {
        name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: appInsights.outputs.connectionString
      }
    ]
    enableManagedIdentity: true
    tags: tags
  }
}

module adminPortal 'modules/compute/app-service.bicep' = {
  name: 'adminportal-deployment'
  params: {
    appName: 'app-furniture-admin-${environment}-${uniqueSuffix}'
    location: location
    appServicePlanId: appServicePlan.outputs.planId
    runtimeStack: 'NODE|20-lts'
    enableManagedIdentity: true
    tags: tags
  }
}

module ecommerceWeb 'modules/compute/app-service.bicep' = {
  name: 'ecommerce-deployment'
  params: {
    appName: 'app-ecommerce-${environment}-${uniqueSuffix}'
    location: location
    appServicePlanId: appServicePlan.outputs.planId
    runtimeStack: 'NODE|20-lts'
    enableManagedIdentity: true
    tags: tags
  }
}

module acr 'modules/compute/container-registry.bicep' = {
  name: 'acr-deployment'
  params: {
    registryName: 'acrfurniture${environment}${uniqueSuffix}'
    location: location
    sku: environment == 'prod' ? 'Premium' : 'Basic'
    tags: tags
  }
}

module aks 'modules/compute/aks.bicep' = {
  name: 'aks-deployment'
  params: {
    clusterName: 'aks-furn-${environment}-${take(uniqueSuffix, 6)}'
    location: location
    dnsPrefix: 'aks-furn-${environment}-${take(uniqueSuffix, 6)}'
    nodeCount: environment == 'prod' ? 3 : 1
    vmSize: environment == 'prod' ? 'Standard_D2s_v3' : 'Standard_B2s'
    acrName: acr.outputs.registryName
    enableAutoScaling: environment == 'prod' ? true : false
    tags: tags
  }
}

module functionApp 'modules/compute/function-app.bicep' = {
  name: 'functionapp-deployment'
  params: {
    functionAppName: 'func-furniture-${environment}-${uniqueSuffix}'
    location: location
    storageAccountName: storage.outputs.storageAccountName
    appInsightsConnectionString: appInsights.outputs.connectionString
    runtime: 'dotnet-isolated'
    runtimeVersion: '8.0'
    tags: tags
  }
}

// ============================================================================
// MESSAGING MODULES
// ============================================================================

module serviceBus 'modules/messaging/service-bus.bicep' = {
  name: 'servicebus-deployment'
  params: {
    namespaceName: 'sb-furniture-${environment}-${uniqueSuffix}'
    location: location
    sku: environment == 'prod' ? 'Standard' : 'Basic'
    queues: [
      {
        name: 'order-processing'
        maxDeliveryCount: 10
        lockDuration: 'PT5M'
        enableDeadLetteringOnMessageExpiration: true
      }
    ]
    tags: tags
  }
}

module eventGrid 'modules/messaging/event-grid.bicep' = {
  name: 'eventgrid-deployment'
  params: {
    topicName: 'eg-product-events-${environment}-${uniqueSuffix}'
    location: location
    tags: tags
  }
}

module apim 'modules/messaging/api-management.bicep' = {
  name: 'apim-deployment'
  params: {
    apimName: 'apim-furniture-${environment}-${uniqueSuffix}'
    location: location
    publisherEmail: 'admin@furniture.com'
    publisherName: 'Furniture Dropship'
    sku: environment == 'prod' ? 'Standard' : 'Developer'
    tags: tags
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

output resourceGroupName string = resourceGroup().name
output environment string = environment
output keyVaultUri string = keyVault.outputs.vaultUri
output productServiceUrl string = productService.outputs.defaultHostName
output adminPortalUrl string = adminPortal.outputs.defaultHostName
output ecommerceWebUrl string = ecommerceWeb.outputs.defaultHostName
output acrLoginServer string = acr.outputs.loginServer
output aksClusterName string = aks.outputs.clusterName
output apimGatewayUrl string = apim.outputs.gatewayUrl
