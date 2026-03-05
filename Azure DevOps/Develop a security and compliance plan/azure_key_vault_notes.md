
# Azure Key Vault – Simplified, Easy‑to‑Understand Notes

## 1. Introduction – Why Azure Key Vault Matters
PetDash, an online pet food company, faced an issue with an expired website certificate, which caused security risks. Azure Key Vault helps prevent such problems by securely storing and automatically renewing certificates. It also protects sensitive information such as passwords, API keys, tokens, and cryptographic keys.

Azure Key Vault acts as a central, secure location where developers, apps, and services can store secrets safely instead of exposing them in code or configuration files.

---

## 2. What is Azure Key Vault?
Azure Key Vault is a cloud-based service for securely storing and managing three things:
- **Keys** – used for encryption and signing
- **Secrets** – such as passwords, tokens, and connection strings
- **Certificates** – including SSL/TLS certificates for websites

Key Vault keeps these items safe, tightly controls who can access them, logs every access attempt, and enables automatic certificate renewal.

---

## 3. Core Components: Vaults, Keys, and Secrets

### A. Vaults
A Key Vault is like a highly protected folder that stores your secrets. Organizations often create multiple vaults (for dev, test, prod) to separate and control access. Key Vault stores everything in encrypted form and logs all access.

### B. Keys
Keys are cryptographic objects used for encryption or signing tasks. Applications do NOT get direct access to the key. Instead, the app asks Key Vault to perform operations like encrypt or sign, and Key Vault does it internally.

There are two types:
1. **HSM-protected keys** – extremely secure and hardware-backed
2. **Software-protected keys** – secure but processed in software

### C. Secrets
Secrets are small pieces of sensitive information like API keys, passwords, or connection strings. They are encrypted and stored securely inside the vault.

---

## 4. What Azure Key Vault Is Used For
### 1. Secrets Management
Store app secrets securely instead of embedding them in code.

### 2. Key Management
Control encryption keys used by apps, SQL, storage, and more.

### 3. Certificate Management
Request, store, manage, and automatically renew certificates used by websites or services.

---

## 5. Best Practices for Using Key Vault
| Best Practice | Explanation |
|--------------|-------------|
| Use RBAC roles | Assign least-privileged access such as Key Vault Contributor, not full admin roles. |
| Separate management vs data access | Management controls vault creation; data access controls reading secrets. |
| Store certificates in Key Vault | Helps centralize and automate certificate renewal and deployment. |
| Enable Soft Delete & Purge Protection | Prevents accidental or malicious deletion of keys or secrets. |
| Limit who can modify permissions | Only trusted admins should have permission to manage access policies. |

---

## 6. How Access to Key Vault Works
Azure Key Vault has two independent layers of access:

### A. Management Plane
Controls vault properties, creation, deletion, and access policies. Managed through Azure RBAC roles.

### B. Data Plane
Controls access to secrets, keys, and certificates inside the vault. Uses Key Vault Access Policies.

Apps typically only need **Get** permission to retrieve secrets.

---

## 7. Network Restrictions
You can restrict vault access to:
- Specific Azure VNets
- Specific IP ranges
- Trusted Azure services only

This creates another layer of protection.

---

## 8. Storing a Secret in Azure Key Vault (Concept Summary)
Steps:
1. Create a vault
2. Go to Secrets → Add Secret
3. Give a name and value
4. Save secret
5. Retrieve it through portal, CLI, PowerShell, or SDK

---

## 9. Certificate Management in Key Vault
Azure Key Vault supports several certificate workflows:

### 1. Self-Signed Certificates
Quick and useful for testing, not secure for production.

### 2. CSR (Certificate Signing Request)
Key Vault generates a key and CSR → you send it to a CA → merge the returned certificate. Private key never leaves Key Vault.

### 3. Integrated CA
Key Vault connects directly to a trusted CA. It can:
- Request certificate
- Renew automatically
- Track revocation and expiration

### 4. Import Existing Certificate
You can import .PFX or .PEM certificates with private keys.

---

## 10. Using Certificates with Azure App Service
Once a certificate is stored in Key Vault, you can:
1. Import it directly into App Service
2. Bind it to your custom domain
3. Let Key Vault handle renewals automatically

This ensures secure, always-valid HTTPS for your website.

---

## 11. Summary
Azure Key Vault:
- Centralizes secret management
- Automates certificate lifecycle
- Protects cryptographic keys
- Provides strong access control & logging
- Prevents security gaps caused by human error

It is essential for securely handling sensitive information in any cloud application.
