@description('SQL Server name')
param serverName string

@description('Location')
param location string = resourceGroup().location

@description('Administrator login')
param administratorLogin string

@description('Administrator password')
@secure()
param administratorPassword string

@description('Tags')
param tags object = {}

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: serverName
  location: location
  tags: tags
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorPassword
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
  }
}

// Firewall rule for Azure services
resource firewallRule 'Microsoft.Sql/servers/firewallRules@2022-05-01-preview' = {
  parent: sqlServer
  name: 'AllowAllAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

output serverName string = sqlServer.name
output serverId string = sqlServer.id
output fullyQualifiedDomainName string = sqlServer.properties.fullyQualifiedDomainName
