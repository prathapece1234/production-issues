# **Production Incident: Resolving PostgreSQL DES Decryption Failure by Updating the RHEL System Crypto Policy**

## Overview

A production PostgreSQL server encountered decryption failures while processing data encrypted using the **DES (Data Encryption Standard)** 
algorithm. The application reported a **"Cipher cannot be initialized"** error whenever it attempted to decrypt existing encrypted data.

Initially, the issue was suspected to be related to the PostgreSQL function or OpenSSL configuration. Although the OpenSSL legacy provider 
configuration was already present, the error persisted. A deeper investigation revealed that the **RHEL system crypto policy** was still set to 
**DEFAULT**, which blocks legacy cryptographic algorithms such as DES.

After changing the system crypto policy to **LEGACY** and restarting PostgreSQL, the application successfully decrypted the existing data without 
any further errors.

---

## Environment

| Component            | Details                    |
| -------------------- | -------------------------- |
| Operating System     | Red Hat Enterprise Linux 9 |
| Database             | PostgreSQL 16.9            |
| OpenSSL Version      | OpenSSL 3.0.7              |
| Encryption Algorithm | DES-ECB                    |
| Environment          | Production                 |
| Server               | 192.168.144.101            |

---

## Problem Statement

The application failed while decrypting DES-encrypted data stored in PostgreSQL.

The following error was consistently observed:

```text
ERROR: decrypt error: Cipher cannot be initialized
Cipher type: des-ecb/pad:none
```

The application team suspected that the OpenSSL legacy provider was not enabled on the server.

---

## Requirements

* Identify why DES decryption was failing.
* Verify OpenSSL configuration.
* Validate PostgreSQL functionality.
* Restore compatibility with existing encrypted data.
* Minimize production downtime.

---

## Investigation

### Step 1 – Verify OpenSSL Version

Verified the installed OpenSSL version.

```bash
openssl version
```

Output:

```text
OpenSSL 3.0.7 1 Nov 2022
```

OpenSSL 3 disables legacy cryptographic algorithms such as DES unless legacy support is enabled.

---

### Step 2 – Review OpenSSL Configuration

Reviewed the OpenSSL configuration.

```bash
cat /etc/pki/tls/openssl.cnf
```

Verified that the legacy provider configuration already existed.

```ini
[provider_sect]
default = default_sect
legacy = legacy_sect

[default_sect]
activate = 1

[legacy_sect]
activate = 1
```

Since the configuration was already present, the expectation was that DES should work.

However, the application continued returning the same error.

---

### Step 3 – Validate Application

The application team updated their PostgreSQL function and tested again.

The same error persisted.

```text
ERROR: decrypt error: Cipher cannot be initialized
Cipher type: des-ecb/pad:none
```

This confirmed that neither the PostgreSQL function nor the OpenSSL configuration alone was causing the issue.

---

### Step 4 – Verify RHEL Crypto Policy

The investigation then shifted to the operating system's cryptographic policy.

Checked the current crypto policy.

```bash
update-crypto-policies --show
```

Output:

```text
DEFAULT
```

This was the key finding.

Although the OpenSSL legacy provider had been configured, the RHEL system-wide crypto policy was still set to **DEFAULT**, which prevents 
applications from using legacy algorithms such as DES.

---

## Root Cause

The PostgreSQL server was running **OpenSSL 3.0.7** with the **RHEL DEFAULT crypto policy**.

While the OpenSSL legacy provider configuration had already been enabled, the operating system's crypto policy still blocked legacy algorithms, 
including DES.

As a result, PostgreSQL was unable to initialize the DES cipher, leading to repeated decryption failures.

The issue was caused by the **RHEL system crypto policy**, not by PostgreSQL or the application itself.

---

## Resolution

Verified the current crypto policy.

```bash
update-crypto-policies --show
```

Output:

```text
DEFAULT
```

Updated the system crypto policy.

```bash
sudo update-crypto-policies --set LEGACY
```

Verified the new configuration.

```bash
update-crypto-policies --show
```

Output:

```text
LEGACY
```

Restarted PostgreSQL.

```bash
systemctl restart postgresql-16
```

---

## Validation

Performed end-to-end validation after updating the crypto policy.

Verified:

```bash
update-crypto-policies --show
```

Output:

```text
LEGACY
```

Retested the PostgreSQL decryption function.

Result:

* DES cipher initialized successfully.
* Existing encrypted data decrypted successfully.
* No further **"Cipher cannot be initialized"** errors.
* Application functionality restored.

---

## Outcome

* Successfully restored PostgreSQL DES decryption.
* Eliminated production decryption failures.
* Confirmed OpenSSL configuration was already correct.
* Identified the operating system crypto policy as the actual cause.
* Restored application functionality without modifying database logic.

---

## Root Cause Analysis (RCA)

| Component             | Status                                                   |
| --------------------- | -------------------------------------------------------- |
| PostgreSQL            | Healthy                                                  |
| Database Function     | Working as Designed                                      |
| OpenSSL Configuration | Correct                                                  |
| OpenSSL Version       | 3.0.7                                                    |
| Crypto Policy         | DEFAULT                                                  |
| Legacy DES Cipher     | Blocked                                                  |
| **Root Cause**        | RHEL system crypto policy preventing legacy cipher usage |

---

## Technologies Used

* Red Hat Enterprise Linux 9
* PostgreSQL 16.9
* OpenSSL 3
* Linux System Administration
* OpenSSL Legacy Provider
* RHEL Crypto Policies
* DES Encryption
* Production Troubleshooting
* Root Cause Analysis

---

## Commands Used During Troubleshooting

### Verify OpenSSL Version

```bash
openssl version
```

### Review OpenSSL Configuration

```bash
cat /etc/pki/tls/openssl.cnf
```

### Check Current Crypto Policy

```bash
update-crypto-policies --show
```

### Enable Legacy Crypto Policy

```bash
sudo update-crypto-policies --set LEGACY
```

### Verify Updated Crypto Policy

```bash
update-crypto-policies --show
```

### Restart PostgreSQL

```bash
systemctl restart postgresql-16
```

### Verify PostgreSQL Service

```bash
systemctl status postgresql-16
```

---

## Key Learning

OpenSSL 3 introduces a provider-based cryptographic architecture, but on Red Hat Enterprise Linux, the **system-wide crypto policy** also controls 
which algorithms applications are permitted to use. During this incident, enabling the OpenSSL legacy provider alone was insufficient because the 
operating system remained configured with the **DEFAULT** crypto policy, which blocked DES. By extending the investigation beyond application 
configuration to include the operating system's cryptographic policy, the issue was resolved without changes to the application or database code.

