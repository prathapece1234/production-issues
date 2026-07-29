Linux User Authentication Issue – `pam_sss` Access Denied for Local Service Accounts

## Overview

Resolved a production Linux authentication issue where local service accounts were repeatedly denied during account validation after the 
server was integrated with **SSSD** for centralized LDAP/Active Directory authentication.

The issue generated continuous authentication failures in cron jobs and system logs, impacting monitoring and obscuring genuine 
authentication events. A detailed investigation identified an incorrect PAM authentication flow, and the issue was resolved by updating 
the PAM configuration to correctly handle local users before directory-based authentication.

---

# Environment

| Component             | Details                                |
| --------------------- | -------------------------------------- |
| Operating System      | Red Hat Enterprise Linux (RHEL)        |
| Authentication        | PAM (Pluggable Authentication Modules) |
| Identity Service      | SSSD                                   |
| Directory Service     | Active Directory                       |
| Service               | crond                                  |
| Authentication Module | pam_sss, pam_localuser                 |

---

# Problem Statement

Repeated authentication failures were observed in the system logs for local service accounts executing scheduled cron jobs.

Example log:

```text
crond[xxxx]: pam_sss(crond:account): Access denied for user build: 10 (User not known to the underlying authentication module)
```

Although the **build** account existed locally, every scheduled task generated authentication failures.

---

# Investigation

Performed a systematic investigation to determine whether the issue originated from the operating system, PAM configuration, SSSD service,
or the centralized identity provider.

### Verified Local User

```bash
id build
```

```bash
grep "^build" /etc/passwd
```

Confirmed that the service account existed as a local Linux user.

---

### Verified SSSD Service

```bash
systemctl status sssd
```

Verified that the SSSD daemon was healthy and communicating with the configured identity provider.

---

### Reviewed Authentication Logs

```bash
grep pam_sss /var/log/secure
```

```bash
journalctl -u crond
```

Observed repeated `pam_sss` authentication failures during cron execution.

---

### Reviewed PAM Configuration

```bash
cat /etc/pam.d/system-auth
```

```bash
cat /etc/pam.d/password-auth
```

Identified that account validation was reaching the `pam_sss` module before correctly handling local users.

---

### Verified Directory User Lookup

```bash
getent passwd build
```

Confirmed that the account did not exist in the centralized LDAP/Active Directory directory.

---

# Root Cause

The Linux server was integrated with a centralized authentication service using **SSSD**.

During cron account validation, PAM forwarded the local service account to `pam_sss.so`. Since the account existed only on the local 
server and not in LDAP/Active Directory, SSSD returned:

```text
User not known to the underlying authentication module
```

As a result, PAM generated repeated **Access denied** messages for the local account.

---

# Resolution

Configured PAM to validate local users before querying the centralized identity provider.

Enabled local authorization using:

```bash
authconfig --enablelocauthorize --update
```

This automatically added the required `pam_localuser.so` module to the PAM configuration.

Updated authentication sequence:

```text
account     required      pam_unix.so
account     sufficient    pam_localuser.so
account     sufficient    pam_succeed_if.so uid < 500 quiet
account     [default=bad success=ok user_unknown=ignore] pam_sss.so
account     required      pam_permit.so
```

The updated authentication flow ensured that local users were authenticated through `pam_localuser.so`, while LDAP/Active Directory users 
continued to authenticate through SSSD.

---

# Validation

Verified the updated PAM configuration.

```bash
grep pam_localuser /etc/pam.d/system-auth
```

Restarted the SSSD service.

```bash
systemctl restart sssd
```

Verified service health.

```bash
systemctl status sssd
```

Executed scheduled cron jobs.

```bash
crontab -l
```

Monitored authentication logs.

```bash
tail -f /var/log/secure
```

Confirmed that authentication failures were no longer generated for local service accounts while centralized directory users continued 
to authenticate successfully.

---

# Authentication Workflow

## Before Resolution

```text
Local User (build)
        │
        ▼
PAM Authentication
        │
        ▼
pam_sss
        │
        ▼
LDAP / Active Directory
        │
User Not Found
        │
        ▼
Access Denied
```

---

## After Resolution

```text
Local User (build)
        │
        ▼
PAM Authentication
        │
        ▼
pam_localuser
        │
Local User Verified
        │
        ▼
Authentication Successful
```

Directory users continue through the standard authentication path:

```text
Directory User
        │
        ▼
PAM Authentication
        │
        ▼
pam_sss
        │
        ▼
LDAP / Active Directory
        │
Credentials Verified
        │
        ▼
Authentication Successful
```

---

# Outcome

* Resolved repeated authentication failures for local service accounts.
* Eliminated unnecessary cron authentication alerts.
* Preserved centralized authentication for LDAP/Active Directory users.
* Improved PAM authentication flow for mixed local and directory-based environments.
* Reduced authentication-related operational noise and simplified troubleshooting.

---

# Technologies Used

* Red Hat Enterprise Linux
* PAM (Pluggable Authentication Modules)
* SSSD
* LDAP
* Microsoft Active Directory
* crond
* systemd
* Linux Authentication

---

# Key Learnings

* SSSD authenticates only directory-managed users and is not aware of local Linux accounts.
* The order of PAM modules directly affects the authentication process.
* `pam_localuser.so` should be evaluated before `pam_sss.so` in environments using both local and centralized authentication.
* Proper PAM configuration ensures seamless coexistence of local service accounts and LDAP/Active Directory users.
