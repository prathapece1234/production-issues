# Enterprise Proxmox Infrastructure Deployment & Validation

## Overview

Designed, deployed, and validated an enterprise **Proxmox Virtual Environment (VE)** on Dell PowerEdge infrastructure as part of a VMware 
migration feasibility assessment. The project included compute, networking, SAN storage, VM lifecycle management, clustering, backup and 
disaster recovery, monitoring integration, and interoperability validation with VMware.

---

# Infrastructure Components

* Proxmox VE deployment
* Enterprise SAN Storage (Fibre Channel & iSCSI)
* Linux Bridge Networking
* VLAN Tagging (802.1Q)
* Multi-NIC Virtual Machines
* LVM & LVM-Thin Storage
* Proxmox Backup Server (PBS)
* Veeam Backup & Replication
* SNMP Monitoring
* VMware Interoperability

---

# Responsibilities

## 1. Proxmox Installation & Initial Configuration

Successfully deployed Proxmox VE on enterprise Dell PowerEdge servers.

Activities included:

* Operating system installation
* Initial host configuration
* Repository configuration
* Network configuration
* Storage initialization
* Enterprise SAN connectivity
* Cluster preparation
* Host validation

---

## 2. Virtual Network Configuration

Configured enterprise virtual networking.

Implemented:

* Linux Bridge networking
* Multiple virtual bridges
* VLAN tagging (802.1Q)
* Multi-NIC virtual machines
* Multiple subnet connectivity
* Network isolation
* Gateway validation
* VM communication testing

### Validation

```bash
ip addr

bridge link

bridge vlan show

brctl show
```

---

## 3. Enterprise SAN Storage Configuration

Configured Fibre Channel and iSCSI shared storage for enterprise workloads.

### Fibre Channel SAN

Validated HBA connectivity.

```bash
systool -c fc_host -v | grep port_name
```

Performed:

* WWPN identification
* SAN zoning
* Storage presentation
* LUN masking
* Host discovery
* Multipath configuration

Rescanned storage.

```bash
for host in /sys/class/scsi_host/host*; do
echo "- - -" > $host/scan
done
```

Validated multipath.

```bash
multipath -ll
```

---

### iSCSI Storage

Configured enterprise iSCSI storage.

```bash
iscsiadm -m discovery -t sendtargets -p <SAN-IP>

iscsiadm -m node --login

multipath -ll
```

Validated:

* Target discovery
* Session establishment
* Multipath redundancy
* Shared storage availability

---

## 4. Raw SAN Disk Presentation

Attached enterprise SAN LUNs directly to virtual machines.

```bash
qm set 105 \
-scsi1 /dev/mapper/mpatha,\
cache=none,\
discard=on,\
ssd=1
```

Validated:

* Raw disk performance
* SSD optimisation
* TRIM support
* SAN compatibility

---

## 5. Hardware Hotplug Validation

Performed online resource scalability testing.

Validated:

* Memory Hotplug
* CPU Hotplug
* Online resource expansion
* Guest operating system detection

### Observations

* Memory expansion supported online.
* CPU Hotplug supported only up to the configured maximum vCPU.
* Increasing maximum vCPU requires a VM shutdown.

---

## 6. LVM & LVM-Thin Storage

Configured enterprise storage pools.

Created:

* Volume Groups
* Thin Pools
* Backup Volumes

Example:

```bash
pvcreate /dev/mapper/mpathb

vgcreate vg_iscsi_mpath /dev/mapper/mpathb

lvcreate -L 100G -T vg_iscsi_mpath/thin_iscsi_pool
```

Configured backup storage.

```bash
mkfs.xfs

mount
```

Validated:

* Snapshot capability
* Thin provisioning
* Storage expansion

---

## 7. Snapshot Validation

Performed snapshot capability assessment.

Verified:

* Standard LVM limitations
* LVM-Thin snapshot functionality
* Snapshot creation
* Snapshot restoration
* Snapshot performance

---

## 8. Cluster Configuration

Configured Proxmox cluster services.

Created cluster.

```bash
pvecm create production-cluster
```

Joined nodes.

```bash
pvecm add <cluster-ip>
```

Validated:

* Cluster communication
* Node synchronization
* Quorum
* Cluster services

---

## 9. Live Migration Validation

Validated virtual machine migration.

Verified:

* Shared storage migration
* Live migration
* Minimal downtime
* Service availability
* Migration rollback

---

## 10. Backup & Disaster Recovery

### Proxmox Backup Server

Designed and implemented enterprise backup infrastructure.

Activities:

* PBS installation
* Storage configuration
* Datastore creation
* Backup scheduling
* Automated backups
* Restore validation
* Garbage collection
* Pruning policies

---

### Backup Validation

Validated:

* Full backup
* Incremental backup
* File-level recovery
* VM recovery
* Database recovery
* Application recovery

---

### Backup Lock Recovery

Identified a backup limitation where interrupted backup jobs left virtual machines in a locked state.

Unlocked affected virtual machines.

```bash
qm unlock <vmid>
```

Validated:

* Backup retry
* Restore functionality
* VM consistency

---

## 11. Veeam Integration

Integrated Proxmox with Veeam Backup & Replication.

Validated:

* VM backup
* VM restore
* Restore as new VM
* VMware interoperability

Documented current Veeam limitations for VM replication.

---

## 12. SNMP Monitoring

Configured SNMP monitoring.

Activities:

* SNMP installation
* Agent configuration
* Monitoring validation
* Infrastructure integration

---

# Frequently Used Commands

### Cluster

```bash
pvecm status

pvecm nodes
```

---

### Virtual Machines

```bash
qm list

qm status <vmid>

qm config <vmid>

qm start <vmid>

qm stop <vmid>

qm reboot <vmid>

qm unlock <vmid>
```

---

### Storage

```bash
pvesm status

multipath -ll

iscsiadm -m session

lsblk
```

---

### Backup

```bash
proxmox-backup-manager datastore list

proxmox-backup-manager garbage-collection start

proxmox-backup-manager prune-job list
```

---

### Network

```bash
ip addr

bridge vlan show

bridge link
```

---

# Validation Performed

* Proxmox deployment
* SAN connectivity
* Fibre Channel validation
* iSCSI validation
* Multipath verification
* Multi-NIC testing
* VLAN testing
* Raw disk attachment
* Hotplug validation
* LVM-Thin validation
* Snapshot testing
* Cluster validation
* Live migration
* Backup & restore
* PBS integration
* Veeam integration
* SNMP monitoring
* Cross-platform recovery

---

# Key Achievements

* Successfully deployed an enterprise Proxmox Virtual Environment from scratch.
* Configured Fibre Channel and iSCSI shared storage with multipath redundancy.
* Implemented Linux Bridge networking, VLANs, and multi-NIC virtual machines.
* Validated online CPU and memory hotplug functionality and documented platform limitations.
* Configured LVM-Thin storage pools to enable snapshot functionality.
* Built a Proxmox cluster and validated live migration capabilities.
* Implemented enterprise backup and disaster recovery using Proxmox Backup Server and Veeam Backup & Replication.
* Validated VM backup, restore, and cross-platform recovery between Proxmox and VMware.
* Configured SNMP monitoring for infrastructure observability.
* Created comprehensive operational documentation and production readiness assessment for enterprise adoption.

---
