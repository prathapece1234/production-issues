**Production Incident: Resolving Bitbucket Git Authentication Failure Using SSH Key Authentication**

## Overview

A development team reported that they were unable to push code changes to a Bitbucket repository from a Linux server. Every Git push operation 
failed with an authentication error, preventing deployment of application updates.

Initially, the user attempted to authenticate using their Linux server username and password. Since Bitbucket does not authenticate Git operations 
using Linux system credentials, the authentication failed.

After analysing the repository authentication method, SSH key-based authentication was configured for the user. The public key was added to the 
Bitbucket repository, restoring secure Git access and allowing code pushes to complete successfully.

---

## Environment

| Component        | Details                  |
| ---------------- | ------------------------ |
| Operating System | Red Hat Enterprise Linux |
| Version Control  | Git                      |
| Repository       | Bitbucket                |
| Authentication   | SSH Key                  |
| Environment      | Production / Development |

---

## Problem Statement

The developer was unable to push code to the Bitbucket repository.

Command executed:

```bash
git push origin release/bugfix/VRE_6.0.3.2_MUN-144
```

Observed error:

```text
Fatal: Authentication failed for 'https://bitbucket.org/...'
```

The user entered their Linux server username and password, but authentication continued to fail.

---

## Requirements

* Identify the cause of the Git authentication failure.
* Verify the repository authentication method.
* Configure secure repository access.
* Validate Git connectivity.
* Restore repository access.

---

## Investigation

### Step 1 – Reproduce the Issue

Verified the Git push operation.

```bash
git push origin release/bugfix/VRE_6.0.3.2_MUN-144
```

The push failed with:

```text
Fatal: Authentication failed
```

---

### Step 2 – Review Authentication Method

Reviewed the Git remote configuration.

```bash
git remote -v
```

The repository required authenticated access through Bitbucket.

Further discussion with the user confirmed that they were entering their **Linux login credentials** when prompted for authentication.

Linux user credentials are local to the server and cannot be used to authenticate against a remote Bitbucket repository.

---

### Step 3 – Configure SSH Authentication

Generated a new SSH key pair for the user.

```bash
ssh-keygen -t rsa -b 4096 -C "user@example.com"
```

Displayed the generated public key.

```bash
cat ~/.ssh/id_rsa.pub
```

add the public key with the repository administrator and added it to the user's Bitbucket account Personal Bitbucket settings -> Security -> SSH keys.

---

### Step 4 – Verify SSH Connectivity

Tested SSH authentication.

```bash
ssh -T git@bitbucket.org
```

Response:

```text
authenticated via ssh key
You can use git to connect to Bitbucket. Shell access is disabled
```

This confirmed that SSH authentication was working successfully.

---

## Root Cause

The user attempted to authenticate to the Bitbucket repository using their **Linux operating system username and password**.

Bitbucket authenticates Git operations independently of Linux system accounts and requires supported authentication methods such as:

* SSH keys
* App passwords
* Personal access tokens (depending on repository configuration)

Because no SSH key had been configured for the user, Git authentication failed.

---

## Resolution

* Generated an SSH key pair for the user.
* Added the public key to the Bitbucket repository/account.
* Verified SSH authentication.
* Retested the Git push operation.

After SSH authentication was configured, the repository accepted the connection and the code push completed successfully.

---

## Validation

Verified SSH connectivity.

```bash
ssh -T git@bitbucket.org
```

Successfully authenticated.

Retested:

```bash
git push origin release/bugfix/VRE_6.0.3.2_MUN-144
```

Result:

* Authentication successful.
* Repository access restored.
* Code pushed successfully.

---

## Outcome

* Successfully restored Git repository access.
* Eliminated authentication failures.
* Implemented secure SSH-based authentication.
* Enabled developers to push code without using passwords.
* Improved repository security and usability.

---

## Root Cause Analysis (RCA)

| Component            | Status                                                                                                   |
| -------------------- | -------------------------------------------------------------------------------------------------------- |
| Linux Server         | Healthy                                                                                                  |
| Git Client           | Healthy                                                                                                  |
| Repository           | Available                                                                                                |
| Network Connectivity | Healthy                                                                                                  |
| User Credentials     | Linux credentials used incorrectly                                                                       |
| SSH Authentication   | Not configured                                                                                           |
| **Root Cause**       | Bitbucket repository required SSH authentication, but the user attempted to use Linux system credentials |

---

## Technologies Used

* Red Hat Enterprise Linux
* Git
* Bitbucket
* SSH
* SSH Key Authentication
* Linux User Management
* DevOps
* Version Control
* Production Support

---

## Key Learning

Git repository authentication is independent of Linux operating system authentication. A user's local Linux credentials cannot be used to 
authenticate with remote Git hosting platforms such as Bitbucket. Understanding the repository's supported authentication methods and configuring 
**SSH key-based authentication** provides both secure and seamless access for development workflows.

