param(
    [string]$ResourceGroupName = "rg-furniture-dev-canadacentral-001",
    [string]$Location = "canadacentral",
    [switch]$WhatIf
)

$ErrorActionPreference = "Stop"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Furniture Dropship - Dev Deployment" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# Create resource group
Write-Host "Checking resource group..." -ForegroundColor Yellow
$rg = az group show --name $ResourceGroupName 2>$null | ConvertFrom-Json

if (-not $rg) {
    Write-Host "Creating resource group: $ResourceGroupName" -ForegroundColor Green
    az group create --name $ResourceGroupName --location $Location
} else {
    Write-Host "Resource group exists: $ResourceGroupName" -ForegroundColor Green
}

# Change to bicep directory
Set-Location "$PSScriptRoot\.."

$deploymentName = "furniture-dev-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

Write-Host ""
Write-Host "Deployment Details:" -ForegroundColor Yellow
Write-Host "  Name: $deploymentName" -ForegroundColor White
Write-Host "  Template: main.bicep" -ForegroundColor White
Write-Host "  Parameters: parameters/dev.parameters.json" -ForegroundColor White
Write-Host "  Resource Group: $ResourceGroupName" -ForegroundColor White
Write-Host ""

# Validate
Write-Host "Validating deployment..." -ForegroundColor Yellow
az deployment group validate `
    --resource-group $ResourceGroupName `
    --template-file main.bicep `
    --parameters parameters/dev.parameters.json

if ($LASTEXITCODE -ne 0) {
    Write-Error "Validation failed!"
    exit 1
}

Write-Host "✅ Validation passed" -ForegroundColor Green
Write-Host ""

if ($WhatIf) {
    Write-Host "Running What-If analysis..." -ForegroundColor Yellow
    az deployment group what-if `
        --resource-group $ResourceGroupName `
        --template-file main.bicep `
        --parameters parameters/dev.parameters.json
} else {
    Write-Host "Deploying (15-20 min)..." -ForegroundColor Yellow
    az deployment group create `
        --resource-group $ResourceGroupName `
        --template-file main.bicep `
        --parameters parameters/dev.parameters.json `
        --name $deploymentName

    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "============================================" -ForegroundColor Green
        Write-Host "✅ DEPLOYMENT SUCCESSFUL" -ForegroundColor Green
        Write-Host "============================================" -ForegroundColor Green
        Write-Host ""

        # Show outputs
        Write-Host "Deployment Outputs:" -ForegroundColor Yellow
        az deployment group show `
            --resource-group $ResourceGroupName `
            --name $deploymentName `
            --query properties.outputs
    } else {
        Write-Error "Deployment failed!"
        exit 1
    }
}

Write-Host ""
Write-Host "Deployment script completed" -ForegroundColor Cyan
