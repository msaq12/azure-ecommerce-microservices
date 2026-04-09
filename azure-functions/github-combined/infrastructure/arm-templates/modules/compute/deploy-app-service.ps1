# ===========================
# Deploy App Service for Product Service
# ===========================

# Variables
$resourceGroup = "rg-furniture-dev-eastus-001"
$location = "eastus"
$templateFile = "app-service.json"
$parametersFile = "app-service-parameters.json"
$deploymentName = "app-service-deployment-$(Get-Date -Format 'yyyyMMddHHmmss')"

Write-Host "Deploying App Service to Resource Group: $resourceGroup" -ForegroundColor Green

# IMPORTANT: Update the keyVaultName in app-service-parameters.json first!
# Replace "kv-furniture-dev-XXXXX" with your actual Key Vault name

# Deploy ARM template
az deployment group create `
  --name $deploymentName `
  --resource-group $resourceGroup `
  --template-file $templateFile `
  --parameters $parametersFile `
  --verbose

# Get outputs
Write-Host "`nDeployment Complete!" -ForegroundColor Green
Write-Host "Getting deployment outputs..." -ForegroundColor Yellow

$appServiceName = az deployment group show `
  --name $deploymentName `
  --resource-group $resourceGroup `
  --query 'properties.outputs.appServiceName.value' `
  --output tsv

$appServiceUrl = az deployment group show `
  --name $deploymentName `
  --resource-group $resourceGroup `
  --query 'properties.outputs.appServiceUrl.value' `
  --output tsv

$principalId = az deployment group show `
  --name $deploymentName `
  --resource-group $resourceGroup `
  --query 'properties.outputs.managedIdentityPrincipalId.value' `
  --output tsv

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "DEPLOYMENT OUTPUTS" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "App Service Name: $appServiceName"
Write-Host "App Service URL: $appServiceUrl"
Write-Host "Managed Identity Principal ID: $principalId"
Write-Host "============================================`n" -ForegroundColor Cyan

# Save outputs to file
@"
App Service Deployment Outputs
Generated: $(Get-Date)

App Service Name: $appServiceName
App Service URL: $appServiceUrl
Managed Identity Principal ID: $principalId
"@ | Out-File -FilePath "app-service-outputs.txt"

Write-Host "Outputs saved to: app-service-outputs.txt" -ForegroundColor Green

# Next steps
Write-Host "`nNEXT STEPS:" -ForegroundColor Yellow
Write-Host "1. Grant Key Vault access to Managed Identity:" -ForegroundColor White
Write-Host "   az keyvault set-policy --name <your-kv-name> --object-id $principalId --secret-permissions get list`n" -ForegroundColor Gray
Write-Host "2. Deploy your application code (see Day 7 guide Part 5)" -ForegroundColor White