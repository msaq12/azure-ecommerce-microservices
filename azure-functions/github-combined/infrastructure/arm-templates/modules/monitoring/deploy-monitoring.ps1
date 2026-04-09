# Deploy Log Analytics Workspace first
Write-Host "Deploying Log Analytics Workspace..." -ForegroundColor Cyan
$lawDeployment = az deployment group create --resource-group rg-furniture-dev-eastus-001 --template-file log-analytics-workspace.json --query "properties.outputs" -o json | ConvertFrom-Json

$workspaceId = $lawDeployment.workspaceId.value
if (-not $workspaceId) {
    Write-Host "[X] Failed to get workspace ID from deployment" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Log Analytics Workspace created: $workspaceId" -ForegroundColor Green

# Update parameters file with workspace ID
$paramsFile = Get-Content app-insights-parameters.json | ConvertFrom-Json
$paramsFile.parameters.workspaceResourceId.value = $workspaceId
$paramsFile | ConvertTo-Json -Depth 10 | Set-Content app-insights-parameters.json

# Deploy Application Insights
Write-Host "Deploying Application Insights..." -ForegroundColor Cyan
$appiDeployment = az deployment group create --resource-group rg-furniture-dev-eastus-001 --template-file app-insights.json --parameters app-insights-parameters.json --query "properties.outputs" -o json | ConvertFrom-Json

$connectionString = $appiDeployment.connectionString.value
if (-not $connectionString) {
    Write-Host "[X] Failed to get connection string from deployment" -ForegroundColor Red
    Write-Host "Deployment output was:" -ForegroundColor Yellow
    $appiDeployment | ConvertTo-Json -Depth 5
    exit 1
}
Write-Host "[OK] Application Insights created" -ForegroundColor Green
Write-Host "Connection String: $connectionString" -ForegroundColor Yellow

# Save connection string to Key Vault
Write-Host "Storing in Key Vault..." -ForegroundColor Cyan
$kvName = az keyvault list --resource-group rg-furniture-dev-eastus-001 --query "[0].name" -o tsv
if (-not $kvName) {
    Write-Host "[X] No Key Vault found in resource group" -ForegroundColor Red
    exit 1
}

az keyvault secret set --vault-name $kvName --name "ApplicationInsightsConnectionString" --value $connectionString

Write-Host "[OK] Monitoring infrastructure deployed!" -ForegroundColor Green
