Enterprise Linux Server Provisioning and Storage Standardization on Virtuozzo Private Cloud

## Project Overview

As part of a **Virtuozzo Private Cloud** deployment, I provisioned and standardized multiple Red Hat Enterprise Linux virtual machines before 
application deployment.

The virtual machines were delivered with only the operating system installed. Additional storage disks were attached but not configured, swap space 
was absent, application mount points were missing, and required application users had not been created.

I completed the complete Linux storage provisioning, swap configuration, filesystem creation, and automation using Bash scripting 
to ensure every server followed the same deployment standard.

---

# Environment

| Component        | Details                  |
| ---------------- | ------------------------ |
| Platform         | Virtuozzo Private Cloud  |
| Operating System | Red Hat Enterprise Linux |
| Storage          | LVM                      |
| Filesystem       | XFS                      |
| Automation       | Bash Shell Scripting     |

---

# Server Roles

The environment consisted of different server roles.

* Database Servers
* Application Servers
* OCS Servers
* DRA Servers
* Data Servers
* Reporting Servers
* Grafana Monitoring Server
* Backup Server
* OpsRamp Monitoring Server

Each server required different storage layouts based on application requirements.

---

# Implementation

## Step 1 – Verify Newly Attached Storage

Verified that the additional virtual disks were available before configuring storage.

```bash
lsblk
fdisk -l
```

Verified existing LVM configuration.

```bash
pvs
vgs
lvs
```

---

## Step 2 – Configure LVM

Initialized the newly attached disks as Physical Volumes.

```bash
pvcreate /dev/sdb
```

Created the Volume Group.

```bash
vgcreate rhel /dev/sdb
```

Created Logical Volumes according to the application requirements.

Example for Application Servers

```bash
lvcreate -L 30G -n apps rhel
lvcreate -L 20G -n app1 rhel
lvcreate -L 30G -n app2 rhel
lvcreate -L 5G -n loggers rhel
```

Example for OCS and Data Servers

```bash
lvcreate -L 40G -n apps rhel
lvcreate -L 40G -n loggers rhel
```

Example for Reporting Server

```bash
lvcreate -L 100G -n APP_REPORTS rhel
```

To reduce manual effort, storage provisioning for similar servers was automated using Bash loops.

Example

```bash
for lv in apps loggers
do
    lvcreate -L 40G -n $lv rhel
done
```

---

## Step 3 – Create XFS Filesystems

Formatted each Logical Volume using XFS.

```bash
mkfs.xfs /dev/rhel/apps
mkfs.xfs /dev/rhel/loggers
mkfs.xfs /dev/rhel/app1
mkfs.xfs /dev/rhel/app2
mkfs.xfs /dev/rhel/APP_REPORTS
```

---

## Step 4 – Create Mount Points

Created the required application directories.

```bash
mkdir -p /apps /loggers /app1 /app2 /APP_REPORTS
```

Mounted the filesystems.

```bash
mount /dev/rhel/apps /apps
mount /dev/rhel/loggers /loggers
mount /dev/rhel/app1 /app1
mount /dev/rhel/app2 /app2
mount /dev/rhel/APP_REPORTS /APP_REPORTS
```

Verified all filesystems.

```bash
df -h
```

---

## Step 5 – Configure Persistent Mounts

Instead of manually editing `/etc/fstab`, UUIDs were retrieved automatically using `blkid`.

Example

```bash
echo "UUID=$(blkid -s UUID -o value /dev/rhel/apps) /apps xfs defaults 0 0" >> /etc/fstab

echo "UUID=$(blkid -s UUID -o value /dev/rhel/loggers) /loggers xfs defaults 0 0" >> /etc/fstab

echo "UUID=$(blkid -s UUID -o value /dev/rhel/app1) /app1 xfs defaults 0 0" >> /etc/fstab

echo "UUID=$(blkid -s UUID -o value /dev/rhel/app2) /app2 xfs defaults 0 0" >> /etc/fstab

echo "UUID=$(blkid -s UUID -o value /dev/rhel/APP_REPORTS) /APP_REPORTS xfs defaults 0 0" >> /etc/fstab
```

For servers with identical storage layouts, the process was automated.

```bash
for lv in apps loggers
do
    mkdir -p /$lv
    mount /dev/rhel/$lv /$lv
    echo "UUID=$(blkid -s UUID -o value /dev/rhel/$lv) /$lv xfs defaults 0 0" >> /etc/fstab
done
```

Reloaded the system configuration.

```bash
systemctl daemon-reload
```

Validated the configuration.

```bash
mount -a
df -h
```

---

## Step 6 – Configure Swap Space

During validation, no swap space was configured on any server.

```bash
free -h
swapon --show
```

Swap was implemented using dedicated Logical Volumes.

### Database Servers

Configured a **16 GB** swap Logical Volume.

```bash
lvcreate -L 16G -n swap rhel
mkswap /dev/rhel/swap
swapon /dev/rhel/swap

echo "UUID=$(blkid -s UUID -o value /dev/rhel/swap) none swap defaults 0 0" >> /etc/fstab
```

### Application, Monitoring, Backup and Utility Servers

Configured an **8 GB** swap Logical Volume.

```bash
lvcreate -L 8G -n swap rhel
mkswap /dev/rhel/swap
swapon /dev/rhel/swap

echo "UUID=$(blkid -s UUID -o value /dev/rhel/swap) none swap defaults 0 0" >> /etc/fstab
```

Verified swap.

```bash
swapon --show
free -h
```

---

## Validation

After provisioning, all storage and system configurations were validated.

```bash
lsblk
pvs
vgs
lvs

mount

df -h

swapon --show

free -h

cat /etc/fstab
```

Verified:

* Physical Volumes created successfully.
* Volume Groups healthy.
* Logical Volumes available.
* XFS filesystems mounted correctly.
* Persistent mounts configured using UUIDs.
* Swap active on all servers.
* Configuration persisted successfully after reboot testing.

---

# Outcome

* Provisioned Linux storage across multiple Virtuozzo virtual machines using LVM.
* Created XFS filesystems based on application-specific storage requirements.
* Automated mount point creation and persistent `/etc/fstab` configuration using UUIDs.
* Implemented dedicated swap volumes (16 GB for database servers and 8 GB for application and utility servers).
* Standardized Linux server builds across the private cloud environment.
* Reduced manual provisioning time and minimized configuration inconsistencies through automation.

---

# Technologies Used

* Red Hat Enterprise Linux
* Virtuozzo Private Cloud
* LVM (PV, VG, LV)
* XFS Filesystem
* Bash Shell Scripting
* `/etc/fstab` -  UUID-based Mount Configuration
* Swap Management
* System Administration

---

# Key Learning

* Standardized provisioning significantly reduces deployment time and configuration drift across environments.
* UUID-based filesystem entries in `/etc/fstab` provide more reliable mounting than device names.
* LVM enables flexible storage allocation and future capacity expansion.
* -basvmed swap sizing improves system stability while avoiding unnecessary resource allocation.
* Bash automation is highly effective for repetitive Linux administration tasks in large-scale private cloud deployments.
