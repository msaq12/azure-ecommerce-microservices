@description('Cluster name')
param clusterName string

@description('Location')
param location string = resourceGroup().location

@description('DNS prefix')
param dnsPrefix string

@description('Node count')
@minValue(1)
@maxValue(100)
param nodeCount int = 1

@description('VM size')
param vmSize string = 'Standard_B2s'

@description('ACR name to attach')
param acrName string

@description('Enable auto-scaling')
param enableAutoScaling bool = false

@description('Min nodes for auto-scaling')
param minNodeCount int = 1

@description('Max nodes for auto-scaling')
param maxNodeCount int = 3

@description('Tags')
param tags object = {}

resource aks 'Microsoft.ContainerService/managedClusters@2023-05-01' = {
  name: clusterName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: dnsPrefix
    enableRBAC: true
    agentPoolProfiles: [
      {
        name: 'agentpool'
        count: nodeCount
        vmSize: vmSize
        mode: 'System'
        osType: 'Linux'
        enableAutoScaling: enableAutoScaling
        minCount: enableAutoScaling ? minNodeCount : null
        maxCount: enableAutoScaling ? maxNodeCount : null
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      serviceCidr: '10.0.0.0/16'
      dnsServiceIP: '10.0.0.10'
    }
  }
}

// Reference existing ACR
resource existingAcr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  name: acrName
}

// ACR Pull role assignment
resource acrPullRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, aks.id, 'AcrPull')
  scope: existingAcr
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
    principalId: aks.properties.identityProfile.kubeletidentity.objectId
    principalType: 'ServicePrincipal'
  }
}

output clusterName string = aks.name
output controlPlaneFQDN string = aks.properties.fqdn
output principalId string = aks.identity.principalId
