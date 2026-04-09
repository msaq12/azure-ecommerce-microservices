# Storage Account Configuration

## Storage Account Details

- **Name**: [Your storage account name]
- **Resource Group**: rg-furniture-dev-eastus-001
- **Location**: East US
- **SKU**: Standard_LRS
- **Environment**: Development

## Blob Containers

| Container Name | Access Level | Purpose | Lifecycle Policy |
|---------------|--------------|---------|------------------|
| product-images | Blob (Public) | Product photos | None |
| product-videos | Blob (Public) | Product videos | None |
| documents | Private | Invoices, PDFs | None |
| uploads | Private | Temp uploads | Delete after 7 days |
| exports | Private | Data exports | Move to Cool after 30 days |
| backups | Private | Database backups | Archive after 90 days |

## CORS Configuration

Allowed origins:
- https://localhost:3000 (local dev)
- https://*.azurestaticapps.net (production)

## Access Methods

### 1. Storage Account Key (For Admin)
```powershell
az storage account keys list --account-name STORAGE_NAME --resource-group RG_NAME
```

### 2. SAS Token (For Temporary Access)
```powershell
az storage blob generate-sas --account-name NAME --container-name CONTAINER --name BLOB --permissions r --expiry TIME
```

### 3. Managed Identity (For Applications - Coming in Day 5)
Will configure when deploying services.

## Connection String Format