# Azure VMSS Run Command Invoke — Detailed Notes (Part 2)

## 1. Run Command Invoke Overview
Azure VMSS Run Command Invoke allows running commands/scripts directly on VMSS instances **without SSH/RDP**.

Useful for:
- Diagnostics
- Testing connectivity
- Quick troubleshooting

---

## 2. Limitations
- Only last **4096 bytes** of output shown
- Commands run as **elevated user** on Linux
- Only **one command at a time** allowed
- Cannot cancel running command
- VM must have outbound internet

---

## 3. Example Command Used
```
az vmss run-command invoke   -g <resource-group>   -n <vmss-name>   --instance-id <id>   --command-id RunShellScript   --scripts "nc -vz microsoft.com 443"   --query "value[0].message" -o tsv
```
You replaced:
- Resource group
- VMSS name
- Instance ID (2 or 3)

Output:
```
Connection to microsoft.com 443 succeeded!
```

---

## 4. Summary
Run Command Invoke is a powerful tool when you:
- Don’t want to SSH into nodes
- Need quick tests/debugging
- Want to automate checks

It is widely used for DevOps automation.
