**Centralized Git Repository Storage Using NFS for Multi-Server Access**

## Overview

A centralized Git repository storage solution was implemented to support multiple Linux servers in an environment where **only one server had 
internet access and connectivity to GitHub**.

Instead of configuring GitHub access on every server, a shared **Git data directory** was created on the central server. The Git repositories were 
cloned into this directory and exported using **NFS (Network File System)** so that other application servers could access the repositories through 
a shared mount.

To enhance security, NFS access was restricted to authorized client IP addresses only.

---

## Environment

| Component                 | Details                       |
| ------------------------- | ----------------------------- |
| Operating System          | Red Hat Enterprise Linux      |
| Repository Source         | GitHub                        |
| File Sharing              | NFS                           |
| Central Repository Server | Internet-enabled Linux server |
| Client Servers            | Internal Linux servers        |

---

## Requirements

* Maintain a centralized Git repository.
* Allow multiple Linux servers to access the same repository.
* Restrict NFS access to authorized client servers only.
* Provide read/write access for application deployments.

---

## Architecture

```text
                Internet
                    │
              GitHub Repository
                    │
                    ▼
        Central Git Server (NFS Server)
              /gitdata/repositories
                    │
      ┌─────────────┼─────────────┐
      │             │             │
      ▼             ▼             ▼
 Client-1      Client-2      Client-3
   NFS            NFS            NFS
```

---

## Implementation

### Step 1 – Create Central Repository Directory

Created the shared repository directory.

```bash
mkdir -p /gitdata
```

Cloned the required GitHub repositories.

```bash
cd /gitdata

git clone <repository-url>
```

---

### Step 2 – Install and Configure NFS Server

Installed the NFS packages.

```bash
dnf install nfs-utils -y
```

Enabled the NFS service.

```bash
systemctl enable nfs-server
systemctl start nfs-server
```

---

### Step 3 – Configure NFS Export

Configured `/etc/exports`.

Example:

```text
/gitdata 192.168.1.10(rw,sync,no_root_squash)
/gitdata 192.168.1.11(rw,sync,no_root_squash)
/gitdata 192.168.1.12(rw,sync,no_root_squash)
```

Only the required client server IP addresses were allowed to access the share.

Applied the export configuration.

```bash
exportfs -avr
```

Verified the exported shares.

```bash
exportfs -v
```

---

### Step 4 – Configure Firewall (If Required)

Allowed the NFS service.

```bash
firewall-cmd --permanent --add-service=nfs
firewall-cmd --reload
```

---

### Step 5 – Configure Client Servers

Installed the NFS client packages.

```bash
dnf install nfs-utils -y
```

Created the mount point.

```bash
mkdir -p /gitdata
```

Mounted the shared directory.

```bash
mount -t nfs <NFS_Server_IP>:/gitdata /gitdata
```

Verified the mount.

```bash
df -h
```

---

### Step 6 – Persistent Mount

Configured `/etc/fstab` on the client servers.

```text
<NFS_Server_IP>:/gitdata    /gitdata    nfs    defaults,_netdev    0 0
```

Verified the configuration.

```bash
mount -a
```

---

## Validation

Verified:

* Git repositories were accessible from all client servers.
* Read/write permissions functioned correctly.
* Only authorized client IPs could mount the NFS share.
* Repository updates on the central server were immediately visible to all clients.
* NFS service started automatically after reboot.

---

## Outcome

* Successfully centralized Git repository storage.
* Eliminated the need for internet access on every server.
* Enabled multiple Linux servers to use a common Git repository.
* Improved deployment consistency across environments.
* Secured NFS access by allowing only approved client IP addresses.
* Simplified repository management and reduced administrative overhead.

---

## Technologies Used

* Red Hat Enterprise Linux
* Git
* GitHub
* NFS (Network File System)
* `nfs-utils`
* Linux Storage Administration
* Linux Networking

---

## Key Learning

A centralized Git repository server combined with NFS provides an efficient solution for environments where only one server has internet access. 
By cloning repositories once on the central server and exporting the repository directory via NFS, multiple internal servers can access the same 
codebase without requiring direct GitHub connectivity. Restricting NFS exports to authorized client IP addresses enhances security while providing 
a scalable and manageable deployment architecture.
