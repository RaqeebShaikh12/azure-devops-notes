
# Terraform on Azure – Detailed Notes (Sections 42–51)

## 42. Managing Subnets as Independent Terraform Resources
Earlier, you defined subnets inside the Virtual Network resource block.
Now you are learning the more modular + flexible approach:
✔ **Define each subnet as its own managed resource**

This improves:

- Reusability
- Clarity
- Ability to independently update or reference subnets
- Avoids large nested blocks inside VNet

### Why separate subnets?
When subnets are defined as separate resources, Terraform:

- Has granular control
- Can update/delete subnets independently
- Understands explicit dependencies
- Keeps VNet block clean

### Terraform Subnet Resource Structure
Terraform resource type:
`azurerm_subnet`

**You created:**

**Web Subnet**
```hcl
resource "azurerm_subnet" "web_subnet01" {
  name                 = local.subnets[0]
  resource_group_name  = azurerm_resource_group.appgrp.name
  virtual_network_name = azurerm_virtual_network.appnetwork.name
  address_prefixes     = [local.subnet_address_prefix[0]]
}
```

**App Subnet**
```hcl
resource "azurerm_subnet" "app_subnet01" {
  name                 = local.subnets[1]
  resource_group_name  = azurerm_resource_group.appgrp.name
  virtual_network_name = azurerm_virtual_network.appnetwork.name
  address_prefixes     = [local.subnet_address_prefix[1]]
}
```

### Removing Inline Subnets
Since subnets are now separate resources, you removed:
```
subnet { ... }
subnet { ... }
```
from inside the Virtual Network resource.

### Plan Result
After deleting the old VNet from Azure manually (exception to the usual rule):
```
Plan: 3 to add
```

Terraform re-created:

- Virtual Network
- Web Subnet
- App Subnet

### Final Infra
```
VNet
 ├─ Web Subnet
 └─ App Subnet
```

---

## 43. Output Values in Terraform
Output values allow you to:

- View values after apply
- Examine resource attributes (like subnet ID, public IP, NIC ID)
- Pass values to other Terraform modules

### Output Block Structure
**Example you created:**
```hcl
output "web_subnet01_id" {
  value = azurerm_subnet.web_subnet01.id
}
```

✔ **What it does**
After `terraform apply`, the CLI prints:
```
Outputs:

web_subnet01_id = "/subscriptions/xxx/resourceGroups/.../subnets/websubnet01"
```

Outputs are like **return values** from Terraform.

✔ **When outputs are useful**

- Debugging
- Passing values to modules
- Printing IDs you need later
- Viewing assigned IPs, resource IDs

Docs: https://developer.hashicorp.com/terraform/language/values/outputs

---

## 44. Deploying a Public IP Address (PIP)
To expose a VM to the internet, you need:
✔ Public IP
✔ NIC configured to use it

Terraform resource:
`azurerm_public_ip`

**Public IP block example:**
```hcl
resource "azurerm_public_ip" "web_ip" {
  name                = "web-ip"
  location            = local.resource_location
  resource_group_name = azurerm_resource_group.appgrp.name
  allocation_method   = "Static"
}
```

---

## 45. Attaching the Public IP to the Network Interface
Inside NIC resource:
```hcl
ip_configuration {
  ...
  public_ip_address_id = azurerm_public_ip.web_ip.id
}
```

**Plan Result:**
```
1 to add (public IP)
1 to change (NIC to attach IP)
```

**Final Infra Diagram**
```
Internet
   |
Public IP (web_ip)
   |
Network Interface (web_nic)
   |
Subnet → VNet → NSG → VM
```

---

## 46. Network Security Group (NSG)
NSG filters inbound and outbound network traffic.
You need an NSG to:

- Allow RDP (port 3389) for Windows Server
- Apply firewall rules at subnet or NIC level

### Manual NSG Review (Azure Portal)
You configured:

**Inbound Security Rule**

| Setting      | Value |
|-------------|-------|
| Protocol    | TCP   |
| Port        | 3389  |
| Action      | Allow |
| Priority    | 300   |
| Source      | Any   |
| Destination | Any   |

This allows RDP into the VM.

---

## 47. Creating the NSG with Terraform
Terraform block:
```hcl
resource "azurerm_network_security_group" "app_nsg" {
  name                = "app-nsg"
  location            = local.resource_location
  resource_group_name = azurerm_resource_group.appgrp.name

  security_rule {
    name                       = "allow_rdp"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    destination_port_range     = "3389"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
```

---

## 48. Associating NSG with Subnets
NSG does **not** support inline subnet assignment.
You discovered you need a separate resource:
`azurerm_subnet_network_security_group_association`

**You created:**

**Web subnet association**
```hcl
resource "azurerm_subnet_network_security_group_association" "web_subnet_assoc" {
  subnet_id                 = azurerm_subnet.web_subnet01.id
  network_security_group_id = azurerm_network_security_group.app_nsg.id
}
```

**App subnet association**
```hcl
resource "azurerm_subnet_network_security_group_association" "app_subnet_assoc" {
  subnet_id                 = azurerm_subnet.app_subnet01.id
  network_security_group_id = azurerm_network_security_group.app_nsg.id
}
```

---

## 49. Handling a Naming Error (Troubleshooting)
You ran into:

- Incorrect resource name for subnet
- Terraform planned: **4 to add, 1 to change, 1 to destroy**
- Azure refused deletion of public IP because it was still associated with NIC

**Fix Steps Taken:**

- Disassociated public IP from NIC
- Deleted NIC manually
- Deleted incorrect subnet
- Re‑ran `terraform apply`
- Terraform recreated all correct infrastructure

✔ **Lesson Learned**
Terraform state + actual Azure resources must remain perfectly aligned.
Even small name mismatches cause big dependency cascades.

---

## 50. Creating a Windows Virtual Machine Using Terraform
Terraform has:

- `azurerm_windows_virtual_machine`
- `azurerm_linux_virtual_machine`

You used the **Windows VM** block.

**VM Terraform Block (Simplified Example)**
```hcl
resource "azurerm_windows_virtual_machine" "webvm01" {
  name                  = "webvm01"
  location              = local.resource_location
  resource_group_name   = azurerm_resource_group.appgrp.name
  size                  = "Standard_B2s"
  admin_username        = "azureuser"
  admin_password        = "Azure@123"

  network_interface_ids = [
    azurerm_network_interface.webnic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter"
    version   = "latest"
  }
}
```

**VM Deployment Result**
Terraform created:

- VM
- OS Disk

You connected via RDP using:
✔ public IP
✔ port 3389
✔ admin username/password

---

## 51. Understanding Terraform State File (Deep Dive)
State file (`terraform.tfstate`) contains:

- All Terraform-managed objects
- Raw Azure resource IDs
- Attribute values (IP, disk name, subnet ID, NIC ID)
- Provider metadata

### Why state is critical?
Terraform uses it to:

- Track what exists
- Prevent duplicate creation
- Detect changes
- Track dependencies
- Map Terraform objects ↔ Azure resources

### Structure Example (Simplified)
```json
{
  "resources": [
    {
      "type": "azurerm_virtual_network",
      "name": "appnetwork",
      "instances": [{
        "attributes": {
          "name": "app-network",
          "address_space": ["10.0.0.0/16"]
        }
      }]
    },
    {
      "type": "azurerm_windows_virtual_machine",
      "name": "webvm01",
      "instances": [{
        "attributes": {
          "id": "/subscriptions/.../virtualMachines/webvm01",
          "os_disk": {"...": "..."},
          "public_ip": null
        }
      }]
    }
  ]
}
```

**Why review the state file?**
Later topics (variables, modules, outputs) require understanding what Terraform actually stores.
