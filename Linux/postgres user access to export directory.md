**Granting PostgreSQL User Access to NFS Export Directory Using POSIX ACLs**

## Overview

A request was received to provide the **`postgres`** user with access to the **`/exports`** directory on the server **192.168.144.38**. Rather than 
modifying directory ownership or broad file permissions, access was granted using **POSIX Access Control Lists (ACLs)**, ensuring that only the 
required user received the necessary permissions while preserving existing ownership and security.

---

## Environment

| Component        | Details                  |
| ---------------- | ------------------------ |
| Operating System | Red Hat Enterprise Linux |
| Server           | 192.168.144.38           |
| Directory        | `/exports`               |
| User             | `postgres`               |
| Access Method    | POSIX ACL (`setfacl`)    |

---

## Request

Provide the `postgres` user with the required access permissions on the `/exports` directory without affecting existing ownership or permissions 
for other users.

---

## Investigation

Verified the current directory permissions.

```bash
ls -ld /exports
```

Checked for any existing Access Control Lists (ACLs).

```bash
getfacl /exports
```

Confirmed that the required permissions for the `postgres` user were not present.

---

## Resolution

Granted the required permissions to the `postgres` user using POSIX ACLs.

```bash
setfacl -m u:postgres:rwx /exports
```

Verified that the ACL entry was successfully applied.

```bash
getfacl /exports
```

The output confirmed that the `postgres` user had been granted the required `rwx` permissions while leaving existing ownership and permissions 
unchanged.

---

## Validation

Verified:

* ACL entry successfully added for the `postgres` user.
* Existing directory ownership remained unchanged.
* Existing user permissions were unaffected.
* The application team confirmed that the `postgres` user was able to access the `/exports` directory without any issues.

---

## Outcome

* Successfully granted access to the `postgres` user using POSIX ACLs.
* Preserved existing file ownership and standard permissions.
* Resolved the access issue without impacting other users or services.
* Application team confirmed successful access after the change.

---

## Technologies Used

* Red Hat Enterprise Linux
* POSIX ACLs
* `setfacl`
* `getfacl`
* Linux File Permissions
* Linux System Administration

---

## Key Learning

POSIX ACLs provide a flexible and secure method to grant user-specific permissions without changing directory ownership or broadening standard 
Unix permission bits. Using ACLs is a best practice when additional access is required for specific users while maintaining the existing security 
model.
