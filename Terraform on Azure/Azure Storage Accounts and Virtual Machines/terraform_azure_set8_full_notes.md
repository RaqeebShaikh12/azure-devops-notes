
# Terraform on Azure – Detailed Notes (Set 8 – Part 1)

## 78. Installing a Web Server on a Windows VM (Manual IIS Setup)
When deploying a Windows Server VM, you often need to host a web application. To do that, the first step is
installing a web server. On Windows, this means enabling **Internet Information Services (IIS)**.

### Manual Steps Performed
1. Connected to the VM using RDP (admin password retrieved from Key Vault).
2. On login, Server Manager opened automatically.
3. Navigated to **Add Roles and Features**.
4. Selected **Web Server (IIS)** role.
5. Installed the role.
6. Configured NSG to allow inbound HTTP (port 80).
7. Verified web server via browser using VM public IP.

These steps demonstrated the *manual* approach before introducing automation using Terraform.

---

## 79. Custom Script Extension (CSE) Overview
Custom Script Extension is an Azure virtual machine extension that downloads and executes scripts
after the VM is deployed.

You prepared a **PowerShell script (iis.ps1)** to:
- Install IIS web server components
- Generate a default HTML file

This script is stored in an Azure Storage Account. The CSE downloads it and executes it automatically.

---

## 80. Preparing Storage Account for Script Hosting
Since CSE cannot read local files directly, you:
1. Created a storage account.
2. Created a container (`scripts`).
3. Uploaded `iis.ps1` to the container.
4. Used the blob URL in the extension configuration.

Blob URL format:
```
https://<storageaccount>.blob.core.windows.net/scripts/iis.ps1
```

---

## 81. Custom Script Extension Terraform Block
A new resource was added:

```hcl
resource "azurerm_virtual_machine_extension" "install_iis" {
  name                 = "iis-install"
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  virtual_machine_id   = azurerm_windows_virtual_machine.webvm["webvm01"].id

  settings = <<SETTINGS
  {
    "fileUris": [
      "https://${azurerm_storage_account.sa.name}.blob.core.windows.net/${azurerm_storage_container.scripts.name}/${azurerm_storage_blob.iis_script.name}"
    ],
    "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File iis.ps1"
  }
  SETTINGS
}
```

The CSE:
- Downloads script
- Executes it using PowerShell
- Installs IIS automatically

---

## 82. NSG Rule for Port 80
An inbound rule was added to allow HTTP traffic:
- Port: **80**
- Protocol: TCP
- Source: Any
- Action: Allow

This is required for public browsing of the IIS web server.

---

## 83. Verifying IIS Deployment
Steps confirmed:
1. VM successfully provisioned.
2. Custom script extension ran successfully.
3. Blob and script exist.
4. `http://<public-ip>` shows IIS.
5. `/default.html` displays your custom page.

Automation validated.

---

## 84. Dynamic Blocks in Terraform
Dynamic blocks allow you to generate repeated nested configuration blocks.

Example: multiple NSG rules inside a single NSG resource.

### Local values:
```hcl
locals {
  security_rules = [
    { priority = 300, port = 3389 },
    { priority = 310, port = 80 }
  ]
}
```

### Dynamic block:
```hcl
dynamic "security_rule" {
  for_each = local.security_rules
  content {
    name                       = "allow-${security_rule.value.port}"
    priority                   = security_rule.value.priority
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    destination_port_range     = security_rule.value.port
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
```

Terraform generates 2 security_rule blocks automatically.

---

## 85. Provisioners in Terraform
Provisioners allow you to run actions on local or remote machines.

### Types:
- `file` → copy files
- `remote-exec` → run remote commands
- `local-exec` → run commands on your local system

Used when post-deployment configuration is needed.

---

## 86. File Provisioner (Copying HTML to Linux Server)
To deploy a custom HTML homepage to an nginx server:

### Step 1: Copy file to VM
```hcl
provisioner "file" {
  source      = "default.html"
  destination = "/home/linuxadmin/default.html"
}
```

This uploads the file into the VM via SSH.
