# Deployment Runbook — Azure Furniture Dropshipping Platform

**Resource Group**: `rg-furniture-dev-eastus-001`
**Azure DevOps Org**: your org → project `FurnitureDropship`

---

## Prerequisites

```powershell
# Login
az login
az account set --subscription 751a8b54-7f4d-405e-b709-c57be5a4e2a4
az aks get-credentials --resource-group rg-furniture-dev-eastus-001 --name aks-furniture-dev
```

---

## Service Startup Order

Some services have cost-saving stop/start states. Start in this order:

### 1. Start AKS (for Order Service)

```powershell
az aks start --name aks-furniture-dev --resource-group rg-furniture-dev-eastus-001
# Wait ~3-5 minutes
kubectl get nodes   # all nodes Ready
kubectl get pods -n furniture-dev   # order-service pods Running
```

### 2. Verify Product Service

```powershell
Invoke-RestMethod https://app-product-service-dev.azurewebsites.net/api/products
# Should return product array
```

### 3. Verify APIM Gateway

```powershell
$KEY = az apim subscription show --resource-group rg-furniture-dev-eastus-001 --service-name apim-furniture-dev --subscription-id master --query primaryKey -o tsv

curl.exe -H "Ocp-Apim-Subscription-Key: $KEY" https://apim-furniture-dev.azure-api.net/products/api/products
curl.exe -H "Ocp-Apim-Subscription-Key: $KEY" https://apim-furniture-dev.azure-api.net/orders/api/orders
```

### 4. Verify Frontends

E-commerce: https://app-furniture-ecommerce-dev-dudqdpakerefarb8.canadacentral-01.azurewebsites.net
Admin: https://app-furniture-admin-dev-188.azurewebsites.net

---

## Cost-Saving Shutdown

```powershell
# Stop AKS when not needed (~$75/month savings)
az aks stop --name aks-furniture-dev --resource-group rg-furniture-dev-eastus-001
```

App Services (Product, Admin, E-commerce) run on B1 plan — leave running or scale to F1 for zero cost.

---

## Deploying Code Changes

### Product Service

Push to `main` branch of `product-service` repo → CI/CD pipeline runs automatically.

Manual trigger:

Azure DevOps → Pipelines → product-service CI → Run pipeline

### Order Service

```powershell
cd order-service
docker build -f OrderService.Api/Dockerfile -t order-service:v1.0 .
docker tag order-service:v1.0 dockerregistrydevenv.azurecr.io/order-service:latest
az acr login --name dockerregistrydevenv
docker push dockerregistrydevenv.azurecr.io/order-service:latest
kubectl rollout restart deployment order-service -n furniture-dev
kubectl rollout status deployment order-service -n furniture-dev
```

### Admin Portal / E-commerce

Push to `main` → CI/CD pipeline auto-deploys.

---

## Updating APIM Backend (if Order Service IP changes)

```powershell
# Get new IP
kubectl get service order-service -n furniture-dev -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

# Update in portal:
# API Management → apim-furniture-dev → APIs → Order API → Settings → Web service URL
# Set to: http://[new-ip]
```

---

## Key Vault Secrets Reference

| Secret Name                   | Used By                  |
| ----------------------------- | ------------------------ |
| `CosmosConnectionString`      | Product Service          |
| `RedisConnectionString`       | Product Service          |
| `SqlConnectionString`         | Order Service            |
| `ServiceBusConnectionString`  | Order Service, Functions |
| `BlobStorageConnectionString` | Functions                |

Access: Azure Portal → Key Vault `kv-furniture-dev-[unique]` → Secrets

---

## Monitoring

**Application Insights**: portal.azure.com → `appinsights-furniture-dev`

- Live Metrics: real-time request stream
- Failures: exception analysis
- Performance: response time by operation
- Transaction search: trace a specific request end-to-end

**Log Analytics Queries**:

```kusto
// Failed requests last hour
requests
| where timestamp > ago(1h) and success == false
| summarize count() by name, resultCode

// Slow requests (>1s)
requests
| where timestamp > ago(1h) and duration > 1000
| summarize avg(duration) by name
| order by avg_duration desc
```

---

## Infrastructure as Code

Full environment rebuild:

```powershell
cd infrastructure
# Deploy in order:
.\deploy-storage.ps1
.\deploy-databases.ps1
.\deploy-keyvault.ps1
.\deploy-appservice.ps1
.\deploy-aks.ps1
.\deploy-apim.ps1      # takes 30-45 min
.\deploy-functions.ps1
```

---

## Rollback Procedure

### App Service (Product/Admin/E-commerce)

Azure Portal → App Service → Deployment Center → Deployment history → Redeploy previous

### Order Service (AKS)

```powershell
kubectl rollout undo deployment order-service -n furniture-dev
kubectl rollout status deployment order-service -n furniture-dev
```

### Database

- Azure SQL: Point-in-time restore (7-day retention on Basic)
- Cosmos DB: Continuous backup (restore via portal)
