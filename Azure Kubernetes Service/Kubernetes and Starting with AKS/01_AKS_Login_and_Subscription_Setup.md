# 1. AKS Login and Subscription Setup

## Logging into Azure via Azure CLI
Azure CLI provides two ways to authenticate:

### **Method 1 — Standard Login (opens browser)**
```
az login
```

### **Method 2 — Device Code Login (recommended)**
```
az login --use-device-code
```
Steps:
1. CLI prints a login URL.
2. Open it in a private browser.
3. Enter the device code.
4. Authenticate.

---

## Setting the Correct Azure Subscription
If you have multiple subscriptions, select where AKS will be created.

### Find subscription in Azure Portal
Azure Portal → Subscriptions → Copy Subscription ID.

### Set subscription
```
az account set --subscription <SUBSCRIPTION_ID>
```

You can now run AKS CLI commands.
