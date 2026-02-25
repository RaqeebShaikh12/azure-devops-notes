
# Terraform on Azure – Detailed Notes (Set 8 – Part 2)

## 87. Remote Exec Provisioner (Moving HTML to nginx directory)
After copying the file, Terraform uses `remote-exec` to move it to the nginx root directory:

```hcl
provisioner "remote-exec" {
  inline = [
    "sudo cp /home/linuxadmin/default.html /var/www/html/default.html"
  ]
}
```

### SSH Connection Block
```hcl
connection {
  type     = "ssh"
  host     = azurerm_public_ip.appip["appvm01"].ip_address
  user     = "linuxadmin"
  password = var.admin_password
}
```

This establishes the SSH session required to execute remote commands.

---

## 88. depends_on for Provisioners
Provisioners do **not** participate in dependency graph unless explicitly declared.

You added:

```hcl
depends_on = [ azurerm_network_security_group.app_nsg ]
```

So SSH port (22) is open before provisioners run.

---

## 89. Azure Bastion Deployment
Azure Bastion provides secure RDP/SSH access without VM public IPs.

### Requirements:
- Subnet **must** be named: `AzureBastionSubnet`
- Public IP (Standard SKU)
- Bastion host resource

### Bastion Subnet:
```hcl
resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  address_prefixes     = ["10.0.3.0/27"]
  resource_group_name  = azurerm_resource_group.appgrp.name
  virtual_network_name = azurerm_virtual_network.appnetwork.name
}
```

### Bastion Host:
```hcl
resource "azurerm_bastion_host" "bastion" {
  name                = "app-bastion"
  location            = local.resource_location
  resource_group_name = azurerm_resource_group.appgrp.name

  ip_configuration {
    name                 = "config"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastionpip.id
  }
}
```

You validated connectivity via Azure Portal.

---

## 90. Connecting to Windows & Linux VMs Through Bastion
From Azure Portal → **Connect → Bastion**:
- Windows: RDP session inside browser
- Linux: SSH session inside browser

No public IP needed.

---

## 91. Cloud-init for Linux VM Bootstrapping
Cloud-init enables running initialization scripts for Linux VMs on first boot.

### Example cloud-init file:
```yaml
#cloud-config
package_update: true
packages:
  - nginx
```

Terraform usage:
```hcl
custom_data = base64encode(data.local_file.cloudinit.content)
```

VM launches with nginx installed automatically.

---

## 92. Reading Files with `data.local_file`
To read local cloud-init file:

```hcl
data "local_file" "cloudinit" {
  filename = "${path.module}/cloudinit"
}
```

This provides file content for VM initialization.

---

## 93. Restructuring Input Variables
You redesigned variable structure to support:
- Multiple subnets
- Multiple NICs & Public IPs per subnet
- Multiple VMs per subnet

### New variable structure:
```hcl
variable "app_environment" {
  type = map(object({
    virtual_network_name = string
    virtual_network_cidr = string
    subnets = map(object({
      cidr_block = string
      machines = map(object({
        network_interface_name = string
        public_ip_name         = string
      }))
    }))
  }))
}
```

This supports scalable network + VM definitions.

---

## 94. Linux VM Deployment (Ubuntu Server)
VM creation block:
```hcl
resource "azurerm_linux_virtual_machine" "appvm" {
  for_each              = var.app_environment["production"].subnets["app-subnet01"].machines
  name                  = each.key
  location              = local.resource_location
  resource_group_name   = azurerm_resource_group.appgrp.name
  size                  = "Standard_B1s"
  admin_username        = "linuxadmin"
  admin_password        = var.admin_password
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.appnic[each.key].id
  ]

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = base64encode(data.local_file.cloudinit.content)
}
```

Result: Ubuntu VM deployed with nginx running.

---

## 95. Understanding Terraform State Indexing
State file shows EXACT managed resource mapping.

Examples:
```
azurerm_network_interface.webnic["webvm01"]
azurerm_network_interface.webnic["appvm01"]
```

Terraform uses:
- `count` → numeric index keys
- `for_each` → string index keys

Checking state helps debug complex loops.

---

**End of Set 8 detailed notes.**
