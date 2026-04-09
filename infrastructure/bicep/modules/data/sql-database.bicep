@description('SQL Server name')
param serverName string

@description('Database name')
param databaseName string

@description('Location')
param location string = resourceGroup().location

@description('SKU (Basic, S0, S1, P1)')
param sku string = 'Basic'

@description('Max size in bytes')
param maxSizeBytes int = 2147483648  // 2GB

@description('Tags')
param tags object = {}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  name: '${serverName}/${databaseName}'
  location: location
  tags: tags
  sku: {
    name: sku
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: maxSizeBytes
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    zoneRedundant: false
    readScale: 'Disabled'
    requestedBackupStorageRedundancy: 'Local'
  }
}

output databaseName string = databaseName
output databaseId string = sqlDatabase.id
