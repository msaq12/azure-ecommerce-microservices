# Deployment Commands Reference

## Validate Deployment

```powershell
cd C:\dev\furniture-dropship\infrastructure\bicep
.\scripts\deploy-dev.ps1 -WhatIf
```

## Deploy to Dev

```powershell
.\scripts\deploy-dev.ps1
```

## Deploy to Test Resource Group

```powershell
.\scripts\deploy-dev.ps1 -ResourceGroupName rg-furniture-test-canadacentral-001
```

## Tear Down & Rebuild Test

### Step 1: Delete Resource Group

```powershell
az group delete --name rg-furniture-test-canadacentral-001 --yes
```

### Step 2: Wait for Deletion (10 minutes)

```powershell
# Wait 10 minutes for deletion to complete
```

### Step 3: Rebuild from Code

```powershell
.\scripts\deploy-dev.ps1 -ResourceGroupName rg-furniture-test-canadacentral-001
```

## Verify Deployment

### List All Resources

```powershell
az resource list --resource-group rg-furniture-test-canadacentral-001 --output table
```

### Count Resources

```powershell
az resource list --resource-group rg-furniture-test-canadacentral-001 --query "length(@)"
```

### Check Child Resources

#### Service Bus Queue

```powershell
az servicebus queue show --resource-group rg-furniture-test-canadacentral-001 --namespace-name sb-furniture-dev-{uniqueSuffix} --name order-processing
```

#### Cosmos Database

```powershell
az cosmosdb sql database show --account-name cosmos-product-dev-{uniqueSuffix} --resource-group rg-furniture-test-canadacentral-001 --name ProductsDB
```

#### Blob Containers

```powershell
az storage container list --account-name stfurnit{uniqueSuffix} --auth-mode login
```

## Clean Up Test Environment

```powershell
az group delete --name rg-furniture-test-canadacentral-001 --yes
```
