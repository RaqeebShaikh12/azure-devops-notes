# Terraform Azure Networking Part 5 Notes

## 1. Why Use Azure Firewall?
Organizations protect internal resources by placing a firewall at the network boundary. Azure Firewall is a fully managed, scalable service deployed in a special subnet named `AzureFirewallSubnet`.

### Azure Firewall Capabilities
- Inspects inbound and outbound traffic
- Blocks malicious traffic
- Supports NAT, Network, and Application rules

## 2. Terraform Workflow Overview
Before adding the firewall, build initial infrastructure:
- Virtual Network (VNet)
- Web Subnet and App Subnet
- Two VMs (one in each subnet)
- Web server installed via script stored in Storage Account

## 3. Azure Firewall Deployment Requirements
Azure Firewall needs:
1. **AzureFirewallSubnet** — a dedicated subnet
2. **Public IP Address** — for inbound/outbound inspection
3. **Firewall Policy** — contains rule collections
4. **Azure Firewall Resource** — references subnet, IP, and policy

## 4. Terraform Modules for Firewall
A dedicated `firewall` module contains:
- Public IP resource
- Firewall Subnet
- Firewall Policy
- Azure Firewall resource
- Route Table and Routes
- NAT Rule Collections
- Application Rule Collections

## 5. Routing All Traffic via Firewall
A route table forces all VM traffic through the firewall.

### Default Route
```
0.0.0.0/0 → Next Hop: Virtual Appliance (Firewall Private IP)
```

### Subnet Association
The route table is attached to:
- Web Subnet
- App Subnet

## 6. NAT Rules with Terraform
Use case: VMs have no public IPs, but need SSH access.

### Example NAT Mapping
- Firewall Port 4001 → Web VM Port 22
- Firewall Port 4002 → App VM Port 22

### SSH Example
```
ssh linuxadmin@<firewall-ip> -p 4001
```

Terraform uses:
- Map variable to define NAT rules
- Dynamic blocks
- Outputs from network interface module

## 7. Application Rules
By default, Azure Firewall blocks outbound web traffic.

### Allowing microsoft.com
Application rule collection allows VMs to access:
```
microsoft.com
```

### Result
```
curl microsoft.com
```
Returns website content successfully.

## 8. Terraform Registry Modules
Example: Using a virtual network module from the Terraform Registry.

Inputs include:
- Resource Group
- Location
- VNet Address Space
- Subnets

Sometimes registry modules have issues, requiring local fixes.

## 9. Summary of Terraform Modules
- Modules contain reusable Terraform configurations
- Can be local or registry-based
- Inputs via variables
- Outputs return data
- Support `for_each`, `count`, and `depends_on`
- Child modules cannot access parent variables directly

## 10. Architecture Diagram (Text-Based)
### High-Level Overview
```
                 Internet
                     |
             +----------------+
             | Azure Firewall |
             |  Public + NIC  |
             +----------------+
                     |
        --------------------------------
        |                              |
   Web Subnet                     App Subnet
       |                                |
    Web VM                          App VM
```

### NAT Rule Flow
```
ssh → Firewall Public IP : 4001
   → (NAT)
      → Web VM Private IP : 22
```

### Routing Flow
```
VM → Route Table → Azure Firewall → Internet
```
