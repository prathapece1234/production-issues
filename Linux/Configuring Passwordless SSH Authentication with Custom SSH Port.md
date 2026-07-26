**Production Implementation: Configuring Passwordless SSH Authentication with Custom SSH Port**

## Overview

The database administration team requested **passwordless SSH authentication** between multiple production source servers and a destination database 
server to simplify administrative tasks and automation.

The environment used a **non-default SSH port (9321)**, requiring users to specify the port during every SSH connection. To improve usability and 
eliminate manual intervention, SSH key-based authentication and client configuration were implemented.

After generating SSH key pairs, deploying public keys, and configuring the SSH client, users were able to connect seamlessly from the **msp** 
account on the source servers to the **postgres** (and Oracle where required) account on the destination server without entering passwords or 
specifying the custom SSH port.

---

## Environment

| Component         | Details                      |
| ----------------- | ---------------------------- |
| Operating System  | Red Hat Enterprise Linux     |
| Authentication    | SSH Key-Based Authentication |
| SSH Port          | 9321                         |
| Source User       | msp                          |
| Destination Users | postgres, oracle             |
| Environment       | Production                   |

---

## Source Servers

```text
10.63.64.20
10.63.64.21
10.63.64.22
10.63.64.23
```

## Destination Server

```text
10.63.64.28
```

---

## Requirement

The DBA team requested:

* Passwordless SSH authentication.
* Access from **msp** user on source servers.
* Login directly as **postgres** user.
* Support for Oracle user where required.
* Eliminate the need to specify:

```bash
-p 9321
```

for every SSH connection.

---

## Implementation

### Step 1 – Generate SSH Key Pair

Generated an SSH key pair on each source server.

```bash
ssh-keygen -t rsa -b 4096
```

Generated files:

```text
~/.ssh/id_rsa
~/.ssh/id_rsa.pub
```

---

### Step 2 – Copy Public Key

Copied the public key to the destination server.

```bash
ssh-copy-id -p 9321 postgres@10.63.64.28
```

Performed the same configuration for the Oracle user where required.

---

### Step 3 – Configure SSH Client

Since the environment uses a non-standard SSH port, configured the SSH client to avoid specifying the port manually.

Updated:

```text
~/.ssh/config
```

Configuration:

```ini
Host redmspbkp1
    HostName 10.63.64.28
    User postgres
    Port 9321
    IdentityFile ~/.ssh/id_rsa
```

This configuration allows SSH to automatically use:

* Destination IP
* Username
* SSH port
* Private key

without additional command-line options.

---

### Step 4 – Verify Connectivity

Tested passwordless authentication.

```bash
ssh redmspbkp1
```

The login completed successfully without prompting for:

* Password
* Username
* Port number

Example:

```text
Last login:
[postgres@REDMSPBKP1 ~]$
```

---

## Root Cause

This was a planned production implementation to simplify secure administrative access between Linux servers.

Previously:

* Users manually entered passwords.
* Users specified the custom SSH port (`9321`) for every connection.
* Manual authentication increased operational effort and reduced automation capability.

SSH key-based authentication combined with SSH client configuration eliminated these manual steps.

---

## Resolution

* Generated SSH key pairs on all source servers.
* Deployed public keys to the destination server.
* Configured passwordless SSH authentication.
* Created SSH client configuration to automatically use the custom SSH port.
* Validated successful login from all source servers.

---

## Validation

Verified:

```bash
ssh redmspbkp1
```

Confirmed:

* Passwordless authentication successful.
* No username prompt.
* No password prompt.
* No need to specify `-p 9321`.
* Direct login to the destination server as the configured user.

---

## Outcome

* Successfully implemented passwordless authentication.
* Simplified administrator access.
* Eliminated repetitive password entry.
* Removed the need to manually specify the custom SSH port.
* Enabled secure automation for database administration tasks.

---

## Implementation Summary

| Component                   | Status     |
| --------------------------- | ---------- |
| SSH Keys                    | Configured |
| Public Key Deployment       | Completed  |
| Passwordless Authentication | Enabled    |
| SSH Client Configuration    | Configured |
| Custom SSH Port             | Automated  |
| Validation                  | Successful |

---

## Technologies Used

* Red Hat Enterprise Linux
* OpenSSH
* SSH Key Authentication
* SSH Client Configuration
* Linux User Management
* Production Administration
* Infrastructure Automation
---

## Key Learning

Passwordless SSH authentication improves both security and operational efficiency by replacing password-based logins with cryptographic key pairs. 
In environments using non-standard SSH ports, configuring the SSH client (`~/.ssh/config`) further simplifies administration by automatically 
applying the correct hostname, username, port, and identity file. This approach reduces manual effort, minimizes connection errors, and enables 
seamless automation for database administration and operational tasks.

