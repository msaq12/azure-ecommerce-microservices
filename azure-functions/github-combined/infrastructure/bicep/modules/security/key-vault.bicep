@description('Key Vault name')
param vaultName string

@description('Location')
param location string = resourceGroup().location

@description('SKU')
@allowed([
  'standard'
  'premium'
])
param sku string = 'standard'

@description('Enable for deployment')
param enabledForDeployment bool = true

@description('Enable for template deployment')
param enabledForTemplateDeployment bool = true

@description('Enable soft delete')
param enableSoftDelete bool = true

@description('Soft delete retention days')
@minValue(7)
@maxValue(90)
param softDeleteRetentionInDays int = 90

@description('Enable purge protection')
param enablePurgeProtection bool = false

@description('Tags')
param tags object = {}

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: vaultName
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: sku
    }
    tenantId: subscription().tenantId
    enabledForDeployment: enabledForDeployment
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enableSoftDelete: enableSoftDelete
    softDeleteRetentionInDays: softDeleteRetentionInDays
    enablePurgeProtection: enablePurgeProtection ? true : null
    enableRbacAuthorization: false
    accessPolicies: []
    publicNetworkAccess: 'Enabled'
  }
}

output vaultName string = keyVault.name
output vaultUri string = keyVault.properties.vaultUri
output vaultId string = keyVault.id
