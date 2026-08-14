# Linux ACL Troubleshooting – Persistent Access to systemd Coredump Files

## 1. Overview

This incident involved a Linux application support user, `dev_oss`, who required access to application coredump files generated 
under:

```bash
/var/lib/systemd/coredump/
```

The initial problem was caused by the ACL mask restricting the effective permissions of the user.

After correcting the ACL mask, a **second issue was identified**: newly generated coredump files were still being created with restrictive file permissions even though a default ACL had been configured on the coredump directory.

Because the default ACL did not consistently provide the required effective permissions on newly generated coredump files, a **systemd path-triggered ACL remediation mechanism** was implemented.

The final solution used:

```text
systemd .path
      |
      v
coredump directory changes
      |
      v
coredump-acl.service
      |
      v
find newly/current coredump files
      |
      v
setfacl
      |
      v
dev_oss gets required access
```

---

# 2. Environment

| Parameter          | Details                             |
| ------------------ | ----------------------------------- |
| OS                 | RHEL / Enterprise Linux             |
| Application        | Seagull                             |
| Coredump Service   | systemd-coredump                    |
| Coredump Directory | `/var/lib/systemd/coredump/`        |
| Support User       | `dev_oss`                           |
| Coredump Format    | `.zst`                              |
| ACL Tool           | `setfacl` / `getfacl`               |
| Automation         | systemd service + systemd path unit |

---

# 3. Problem Statement

The application support user needed access to application coredumps for troubleshooting.

Initial access resulted in:

```text
Permission denied
```

The directory ACL was inspected:

```bash
getfacl /var/lib/systemd/coredump/
```

The original ACL contained:

```text
user::rwx
user:dev_oss:rwx
group::r-x
mask::r-x
other::r-x
```

The important finding was:

```text
user:dev_oss:rwx
mask::r-x
```

Therefore, the effective permission was restricted to:

```text
r-x
```

instead of the intended:

```text
rwx
```

---

# 4. Initial Resolution – ACL Mask

The ACL mask was corrected:

```bash
setfacl -m u:dev_oss:rwx,m:rwx /var/lib/systemd/coredump/
```

The ACL was verified:

```bash
getfacl /var/lib/systemd/coredump/
```

Result:

```text
user::rwx
user:dev_oss:rwx
group::r-x
mask::rwx
other::r-x
```

At this point, the existing directory permissions were correct.

---

# 5. Persistent Default ACL

To provide ACL inheritance for future filesystem objects, a default ACL was also configured:

```bash
setfacl -m d:u:dev_oss:rwx,d:m:rwx /var/lib/systemd/coredump/
```

Verification:

```bash
getfacl /var/lib/systemd/coredump/
```

Expected:

```text
user::rwx
user:dev_oss:rwx
group::r-x
mask::rwx
other::r-x

default:user::rwx
default:user:dev_oss:rwx
default:group::r-x
default:mask::rwx
default:other::r-x
```

---

# 6. Problem Reappeared With New Coredumps

Despite the directory ACL and default ACL being configured, newly generated coredump files were still observed with restrictive permissions.

Example:

```bash
ls -lrth /var/lib/systemd/coredump/
```

showed files similar to:

```text
-rw-r-----+ 1 root root 144K ... core.seagull....zst
```

The important observation was that the **actual generated coredump file** did not consistently have the required access for `dev_oss`.

Therefore, the investigation moved from:

```text
Directory ACL
```

to:

```text
Actual generated file ACL
```

---

# 7. Root Cause

The issue was not simply the directory permission.

There were two separate ACL-related problems.

### Initial problem

The directory ACL mask restricted the effective permissions:

```text
user:dev_oss:rwx
mask::r-x
```

### Recurring problem

Even after configuring:

```text
default:user:dev_oss:rwx
default:mask::rwx
```

new `systemd-coredump` files were still being generated with restrictive permissions.

Therefore, relying only on the directory's default ACL did not provide the required operational result in this environment.

The final solution was to automatically apply the required ACL to coredump files whenever the coredump directory changed.

---

# 8. Final Resolution

A systemd service and path unit were created.

The two files were:

```text
/etc/systemd/system/coredump-acl.service
/etc/systemd/system/coredump-acl.path
```

---

# 9. ACL Remediation Service

File:

```bash
/etc/systemd/system/coredump-acl.service
```

Configuration:

```ini
[Unit]
Description=Set ACL on systemd coredump files
After=systemd-coredump@.service

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'find /var/lib/systemd/coredump/ -type f -exec setfacl -m u:dev_oss:rwx,m:rwx {} +'
```

### Purpose

The service searches the coredump directory:

```bash
find /var/lib/systemd/coredump/ -type f
```

and applies:

```bash
setfacl -m u:dev_oss:rwx,m:rwx
```

to the files.

Therefore, when the service executes, the coredump files receive the required ACL.

---

# 10. systemd Path Unit

File:

```bash
/etc/systemd/system/coredump-acl.path
```

Configuration:

```ini
[Unit]
Description=Monitor systemd coredump directory

[Path]
PathChanged=/var/lib/systemd/coredump
Unit=coredump-acl.service

[Install]
WantedBy=multi-user.target
```

### Purpose

The `.path` unit monitors:

```text
/var/lib/systemd/coredump
```

When a filesystem change is detected, systemd triggers:

```text
coredump-acl.service
```

The resulting workflow is:

```text
New application crash
        |
        v
systemd-coredump generates .zst
        |
        v
/var/lib/systemd/coredump changes
        |
        v
coredump-acl.path detects change
        |
        v
coredump-acl.service starts
        |
        v
find coredump files
        |
        v
setfacl
        |
        v
dev_oss access restored
```

---

# 11. Enable and Start the Path Unit

After creating the unit files:

```bash
systemctl daemon-reload
```

Enable the path unit:

```bash
systemctl enable coredump-acl.path
```

Start it:

```bash
systemctl start coredump-acl.path
```

Verify:

```bash
systemctl status coredump-acl.path
```

Expected state:

```text
Active: active (waiting)
```

---

# 12. Verify the Service

Check:

```bash
systemctl status coredump-acl.service
```

Because it is:

```ini
Type=oneshot
```

the service is expected to execute its command and exit.

Check its logs:

```bash
journalctl -u coredump-acl.service
```

For the path unit:

```bash
journalctl -u coredump-acl.path
```

---

# 13. Validate ACL on Coredump Files

After a new coredump is generated:

```bash
ls -lrth /var/lib/systemd/coredump/
```

Then inspect the actual file:

```bash
getfacl /var/lib/systemd/coredump/<coredump-file>.zst
```

The expected ACL should include:

```text
user:dev_oss:rwx
mask::rwx
```

The important point is that the ACL is now being applied to the **actual coredump file**, rather than relying only on directory inheritance.

---

# 14. Validate as `dev_oss`

Switch to the affected user:

```bash
su - dev_oss
```

Access the directory:

```bash
cd /var/lib/systemd/coredump/
```

Test the coredump:

```bash
zstd -d <coredump-file>.zst
```

Alternatively, directly test read access:

```bash
test -r /var/lib/systemd/coredump/<coredump-file>.zst
echo $?
```

Expected:

```text
0
```

---

# 15. Why the `.path` + `.service` Approach Was Used

The final implementation was introduced because the following configuration alone did not provide a reliable operational result:

```bash
setfacl -m d:u:dev_oss:rwx,d:m:rwx /var/lib/systemd/coredump/
```

New coredump files were still observed with restrictive permissions.

Instead of manually running:

```bash
setfacl -m u:dev_oss:rwx,m:rwx <file>
```

after every application crash, the ACL correction was automated.

### Before

```text
Application crash
      |
      v
New coredump
      |
      v
Permission denied
      |
      v
Administrator manually runs setfacl
```

### After

```text
Application crash
      |
      v
New coredump
      |
      v
Directory change detected
      |
      v
systemd path unit
      |
      v
ACL service
      |
      v
setfacl automatically executed
      |
      v
dev_oss access
```

This removed the need for manual intervention after each coredump generation.

---

# 16. Troubleshooting Flow

```text
dev_oss receives Permission Denied
              |
              v
Check directory ACL
              |
              v
getfacl /var/lib/systemd/coredump/
              |
              v
ACL mask found restrictive
              |
              v
Correct user ACL + mask
              |
              v
Configure default ACL
              |
              v
New coredump generated
              |
              v
Permission issue occurs again
              |
              v
Inspect actual .zst ACL
              |
              v
New file has restrictive permissions
              |
              v
Default ACL alone not sufficient
              |
              v
Create systemd ACL service
              |
              v
Create systemd path unit
              |
              v
Monitor coredump directory
              |
              v
Automatically execute setfacl
              |
              v
Validate new coredump
              |
              v
dev_oss access successful
```

---

# 17. Important Security Consideration

The implemented service currently applies:

```bash
u:dev_oss:rwx,m:rwx
```

to **all regular files** under:

```text
/var/lib/systemd/coredump/
```

because the command uses:

```bash
find /var/lib/systemd/coredump/ -type f
```

This should therefore be reviewed carefully in a production environment.

Coredump files may contain sensitive application memory, credentials, tokens, configuration information, or customer data.

A more restrictive implementation could grant only the permissions actually required by the support user.

For example, if `dev_oss` only needs to read compressed coredumps, consider:

```bash
setfacl -m u:dev_oss:r,m:rwx <file>
```

with the exact ACL/mask design validated against the application's operational requirement.

The portfolio implementation should document the **business requirement for `rwx`** if full access is intentionally required.

---

# 18. Best Practices

* Always inspect the ACL mask using `getfacl`.
* Distinguish directory ACLs from file ACLs.
* Use default ACLs when inheritance is required.
* Validate the ACL on newly generated files.
* Automate repetitive remediation when manual intervention is operationally undesirable.
* Use systemd `.path` units for event-driven filesystem monitoring.
* Use `systemd` services for controlled remediation actions.
* Avoid `chmod 777`.
* Avoid unrestricted sudo access.
* Protect coredump data because it can contain sensitive process memory.
* Review the permissions granted by automated ACL remediation.
* Test the automation after system reboot.
* Verify the `.path` unit remains enabled and active.
* Validate the actual access as `dev_oss`.

---

# 19. Validation Checklist

```text
[✓] Directory ACL verified
[✓] ACL mask corrected
[✓] Default ACL configured
[✓] New coredump generated
[✓] New file permissions investigated
[✓] Default ACL found insufficient for required operational access
[✓] systemd ACL service created
[✓] systemd path unit created
[✓] Path unit enabled
[✓] Path unit started
[✓] ACL automatically applied to coredump files
[✓] Access tested as dev_oss
[✓] Coredump decompression validated
```

---

# 20. Commands Used

### Check directory ACL

```bash
getfacl /var/lib/systemd/coredump/
```

### Correct current ACL

```bash
setfacl -m u:dev_oss:rwx,m:rwx /var/lib/systemd/coredump/
```

### Configure default ACL

```bash
setfacl -m d:u:dev_oss:rwx,d:m:rwx /var/lib/systemd/coredump/
```

### Check file ACL

```bash
getfacl /var/lib/systemd/coredump/<coredump>.zst
```

### Reload systemd

```bash
systemctl daemon-reload
```

### Enable path monitoring

```bash
systemctl enable coredump-acl.path
```

### Start path monitoring

```bash
systemctl start coredump-acl.path
```

### Check path unit

```bash
systemctl status coredump-acl.path
```

### Check remediation service

```bash
systemctl status coredump-acl.service
```

### Check service logs

```bash
journalctl -u coredump-acl.service
```

### Check path logs

```bash
journalctl -u coredump-acl.path
```

### Test user access

```bash
su - dev_oss
```

```bash
cd /var/lib/systemd/coredump/
```

### Decompress coredump

```bash
zstd -d <coredump-file>.zst
```

---

# 21. Root Cause Analysis

### Initial Root Cause

The directory ACL contained a restrictive ACL mask:

```text
user:dev_oss:rwx
mask::r-x
```

which reduced the effective permission.

### Second Root Cause

After correcting the ACL mask and configuring a default ACL, newly generated coredump files were still observed with restrictive permissions.

Therefore, the default ACL configuration alone did not provide the required operational access to the generated coredump files in this environment.

### Final Corrective Action

A systemd event-driven ACL remediation mechanism was implemented:

```text
systemd-coredump
       |
       v
Coredump directory changes
       |
       v
coredump-acl.path
       |
       v
coredump-acl.service
       |
       v
find + setfacl
       |
       v
dev_oss access
```

This automated the ACL correction whenever the coredump directory changed.

---

# 22. Outcome

The issue was resolved by implementing a layered permission and automation approach:

1. Corrected the ACL mask.
2. Granted the required ACL to `dev_oss`.
3. Configured a default ACL for future objects.
4. Observed that newly generated coredump files could still have restrictive permissions.
5. Implemented a systemd `.path` unit to monitor the coredump directory.
6. Implemented a systemd oneshot service to automatically apply the required ACL.
7. Eliminated the need for manual `setfacl` execution after every coredump.
8. Validated access from the affected `dev_oss` account.

This incident demonstrates practical production experience with **Linux ACLs, systemd-coredump, systemd path units, automated remediation, filesystem permissions, and production troubleshooting**.

---

# 23. Technologies Used

```text
RHEL
Linux
POSIX ACL
getfacl
setfacl
systemd
systemd-coredump
systemd.path
systemd.service
zstd
sudo
Linux Filesystem Permissions
Shell Scripting
Production Troubleshooting
Incident Management
Root Cause Analysis
Automated Remediation
```

---
