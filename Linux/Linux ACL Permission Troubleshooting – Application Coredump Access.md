# Linux ACL Permission Troubleshooting – Application Coredump Access

## 1. Overview

This document describes a Linux production troubleshooting case where an application support user was unable to access and analyze 
application coredump files stored under:

```bash
/var/lib/systemd/coredump/
```

The affected user was:

```text
dev_oss
```

The initial ACL configuration granted `rwx` permissions to `dev_oss`, but the user still experienced permission-related issues.

Investigation identified that the **POSIX ACL mask was limiting the effective permissions** assigned to the user.

A separate issue was also identified when attempting to use `sudo`: the `dev_oss` account was not authorized to execute `/bin/zstd` 
through sudo. This is a **sudoers authorization issue**, independent of the directory ACL problem.

---

## 2. Environment

| Parameter            | Details                      |
| -------------------- | ---------------------------- |
| Operating System     | RHEL / Enterprise Linux      |
| Affected User        | `dev_oss`                    |
| Directory            | `/var/lib/systemd/coredump/` |
| File Type            | `.zst` compressed coredump   |
| Application          | Seagull                      |
| Access Method        | Linux filesystem ACL         |
| Analysis Tool        | `zstd`                       |
| Privilege Escalation | `sudo`                       |

---

## 3. Problem Statement

The application support user needed access to application coredump files for troubleshooting.

When attempting to access or decompress a coredump, the user received:

```text
Permission denied
```

Example:

```bash
[dev_oss@testqeg coredump]$ zstd -d core.seagull.1001....zst
zstd: ... : Permission denied
```

An ACL had already been configured for the user:

```bash
setfacl -R -m u:dev_oss:rwx /var/lib/systemd/coredump/
```

However, the expected access was not achieved.

---

# 4. Investigation

## 4.1 Check Directory ACL

The first step was to inspect the ACL on the coredump directory.

```bash
getfacl /var/lib/systemd/coredump/
```

Initial ACL:

```text
# file: coredump/
# owner: root
# group: root

user::rwx
user:dev_oss:rwx        #effective:r-x
group::r-x
mask::r-x
other::r-x
```

The important observation was:

```text
user:dev_oss:rwx
#effective:r-x
mask::r-x
```

Although `dev_oss` had been explicitly granted:

```text
rwx
```

the ACL mask restricted the effective permissions.

---

# 5. Root Cause Analysis

## ACL Mask Restriction

POSIX ACLs use an ACL mask to limit the effective permissions of:

* Named users
* Named groups
* The owning group

In this case:

```text
user:dev_oss:rwx
mask::r-x
```

resulted in:

```text
dev_oss effective permission = r-x
```

Therefore, the explicit `rwx` ACL entry did not translate into effective `rwx` access.

### Before

```text
user:dev_oss:rwx
mask::r-x
```

Effective:

```text
r-x
```

### Required

```text
user:dev_oss:rwx
mask::rwx
```

Effective:

```text
rwx
```

---

# 6. Resolution

The ACL entry and ACL mask were corrected together:

```bash
setfacl -m u:dev_oss:rwx,m:rwx /var/lib/systemd/coredump/
```

Where:

```text
u:dev_oss:rwx
```

grants the user read, write, and execute permissions.

And:

```text
m:rwx
```

sets the ACL mask to allow those permissions to become effective.

---

# 7. Validation

The ACL was checked again:

```bash
getfacl /var/lib/systemd/coredump/
```

Final result:

```text
# file: coredump/
# owner: root
# group: root

user::rwx
user:dev_oss:rwx
group::r-x
mask::rwx
other::r-x
```

The previous effective-permission limitation was removed.

### Before

```text
user:dev_oss:rwx
#effective:r-x
mask::r-x
```

### After

```text
user:dev_oss:rwx
mask::rwx
```

---

# 8. Important File-Level Validation

A critical part of Linux ACL troubleshooting is distinguishing **directory permissions from file permissions**.

The coredump directory ACL was corrected, but individual coredump files can have their own permissions and ACLs.

Example:

```bash
ls -lrth /var/lib/systemd/coredump/
```

Observed files included:

```text
-rw-rwx---+ 1 root root 144K ... core.seagull....zst
-rw-r-----+ 1 root root 144K ... core.seagull....zst
-rw-r-----+ 1 root root 143K ... core.seagull....zst
```

The `+` at the end of the permission string indicates that an extended ACL exists.

Therefore, if the user can enter the directory but cannot read or decompress a particular `.zst` file, the next investigation should 
be:

```bash
getfacl /var/lib/systemd/coredump/<coredump-file>.zst
```

For example:

```bash
getfacl core.seagull.1001.<timestamp>.zst
```

This determines whether the individual coredump file grants the required effective permission to `dev_oss`.

---

# 9. Directory vs File Permission

A useful troubleshooting distinction is:

```text
Directory ACL
      |
      +---- Controls ability to traverse/access directory
      |
      +---- Does NOT automatically change ACLs on existing files
```

For a user to successfully read a coredump:

```text
Directory
   |
   |-- Execute permission
   |
   v
Coredump file
   |
   |-- Read permission
   |
   v
zstd
   |
   v
Coredump analysis
```

Therefore, fixing the directory ACL alone does not necessarily grant read access to every existing coredump file.

---

# 10. `sudo` Investigation

During troubleshooting, the user also attempted:

```bash
sudo zstd -d <coredump-file>.zst
```

The system returned:

```text
Sorry, user dev_oss is not allowed to execute
'/bin/zstd -d ...'
```

This is a separate security control.

The message indicates that the user is **not authorized by the sudo policy** to execute `/bin/zstd`.

Therefore:

```text
Filesystem ACL problem
        ≠
sudo authorization problem
```

The ACL controls filesystem access.

The sudoers configuration controls whether `dev_oss` can execute a command with elevated privileges.

---

# 11. Sudo Validation

The configured sudo permissions can be checked with:

```bash
sudo -l
```

or, where appropriate, by an administrator reviewing:

```bash
/etc/sudoers
/etc/sudoers.d/
```

The recommended approach is to avoid granting unrestricted sudo access.

If business requirements require elevated coredump analysis, use a narrowly scoped sudo rule rather than:

```text
dev_oss ALL=(ALL) ALL
```

A least-privilege approach should be used.

---

# 12. Recommended ACL Troubleshooting Workflow

```text
Permission Denied
       |
       v
Check current user
       |
       v
id dev_oss
       |
       v
Check directory permissions
       |
       v
ls -ld /var/lib/systemd/coredump
       |
       v
Check ACL
       |
       v
getfacl /var/lib/systemd/coredump
       |
       v
Check effective ACL permission
       |
       v
Check ACL mask
       |
       v
Correct user ACL + mask
       |
       v
Check individual coredump file
       |
       v
getfacl <coredump-file>
       |
       v
Validate read permission
       |
       v
Run zstd as dev_oss
       |
       +---- Permission denied
       |          |
       |          v
       |     Check file ACL
       |
       +---- sudo denied
                  |
                  v
             Check sudoers
```

---

# 13. Commands Used

### Check directory permissions

```bash
ls -ld /var/lib/systemd/coredump/
```

### Check ACL

```bash
getfacl /var/lib/systemd/coredump/
```

### Add user ACL

```bash
setfacl -R -m u:dev_oss:rwx /var/lib/systemd/coredump/
```

### Correct ACL mask

```bash
setfacl -m u:dev_oss:rwx,m:rwx /var/lib/systemd/coredump/
```

### Check individual coredump ACL

```bash
getfacl /var/lib/systemd/coredump/<coredump-file>.zst
```

### Check user identity

```bash
id dev_oss
```

### Check sudo authorization

```bash
sudo -l
```

### Test user access

```bash
su - dev_oss
```

```bash
cd /var/lib/systemd/coredump/
```

### Analyze coredump

```bash
zstd -d <coredump-file>.zst
```
---

# 14. Persistent Default ACL for Future Coredump Files
Default ACL Inheritance

To ensure that the dev_oss permission is automatically inherited by future files and directories created under the coredump directory, configure a default ACL:

setfacl -m d:u:dev_oss:rx,d:m:rx /var/lib/systemd/coredump/
What this does
d:u:dev_oss:rx

Configures a default ACL granting dev_oss read and execute permissions on newly created objects under the directory.

d:m:rx

Sets the default ACL mask, which controls the maximum effective permission for the inherited named-user/group ACL entries.

Verify
getfacl /var/lib/systemd/coredump/

Expected output should include:

user::rwx
user:dev_oss:r-x
group::r-x
mask::r-x
other::r-x

default:user::rwx
default:user:dev_oss:r-x
default:group::r-x
default:mask::r-x
default:other::r-x
Important

The d: prefix means these are default ACL entries for future objects.

u:dev_oss:rx     → Current directory ACL
d:u:dev_oss:rx   → Default ACL for future objects

m:rx             → Current ACL mask
d:m:rx           → Default ACL mask for future objects

This configuration is intended for future inheritance. Existing coredump files are not automatically modified; their individual ACLs must be checked separately with:

getfacl /var/lib/systemd/coredump/<coredump-file>.zst

For a support user who only needs to read and analyze coredumps, rx on the directory follows the principle of least privilege.
---

# 15. Security Considerations

Coredumps can contain sensitive application information, including:

* Application memory
* Configuration data
* Runtime information
* Credentials or tokens present in process memory
* Customer/application data

Therefore, broad permissions such as:

```bash
chmod 777 /var/lib/systemd/coredump/
```

should **not** be used as a troubleshooting shortcut.

Similarly, unrestricted sudo access should not be granted just to solve an application-support requirement.

ACLs provide a more controlled method of granting access to specific users.

---

# 16. Best Practices

* Use ACLs instead of broad `777` permissions.
* Always inspect the ACL mask.
* Check `#effective` permissions in `getfacl` output.
* Distinguish directory permissions from file permissions.
* Check individual coredump ACLs when file access fails.
* Use least-privilege sudo rules.
* Avoid unrestricted `sudo` access.
* Protect coredump files because they may contain sensitive information.
* Periodically clean up old coredumps according to the system retention policy.
* Document privileged access requirements.
* Validate permissions as the affected user rather than assuming the ACL is correct.

---

# 17. Key Learning

The main lesson from this incident was that an ACL entry alone does not guarantee the requested effective permission.

For example:

```text
user:dev_oss:rwx
mask::r-x
```

does **not** provide effective `rwx`.

The effective permission is constrained by the mask:

```text
user:dev_oss:rwx
       +
mask::r-x
       =
effective:r-x
```

After correcting the mask:

```text
user:dev_oss:rwx
mask::rwx
```

the user receives the intended effective permissions.

A second important lesson is that:

```text
ACL
```

and:

```text
sudoers
```

solve different authorization problems.

A user can have sufficient filesystem permissions while still being prohibited from executing a command through `sudo`.

---

# 18. Outcome

The coredump directory ACL was corrected by explicitly granting `dev_oss` `rwx` permissions and updating the ACL mask to `rwx`.

The final ACL was verified successfully:

```text
user:dev_oss:rwx
mask::rwx
```

The investigation also identified the separate sudoers restriction preventing `dev_oss` from executing `/bin/zstd` with elevated 
privileges.

The incident demonstrated a structured Linux permission troubleshooting methodology covering:

* POSIX ACLs
* ACL masks
* Effective permissions
* Directory vs file permissions
* Sudo authorization
* Least-privilege access
* Application coredump handling

---

# Technologies Used

* RHEL / Enterprise Linux
* POSIX ACL
* `getfacl`
* `setfacl`
* `zstd`
* `sudo`
* systemd-coredump
* Linux filesystem permissions
* Shell troubleshooting
