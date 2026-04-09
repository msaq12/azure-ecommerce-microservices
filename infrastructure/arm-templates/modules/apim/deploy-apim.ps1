# Deploy APIM Instance
# This takes 30-45 minutes!

$resourceGroup = "rg-furniture-dev-eastus-001"
$templateFile = "apim-instance.json"
$parametersFile = "apim-parameters.json"

Write-Host "Deploying APIM instance..." -ForegroundColor Yellow
Write-Host "This will take 30-45 minutes. Go get coffee!" -ForegroundColor Cyan

az deployment group create `
  --resource-group $resourceGroup `
  --template-file $templateFile `
  --parameters $parametersFile `
  --query "properties.outputs" `
  --output json | Tee-Object -FilePath "apim-outputs.json"

Write-Host "`nAPIM deployment complete!" -ForegroundColor Green
Write-Host "Outputs saved to apim-outputs.json" -ForegroundColor Cyan

# Display outputs
Get-Content "apim-outputs.json" | ConvertFrom-Json
