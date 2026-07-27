# VMware vCenter Server Upgrade (vSphere 7.0.3 → vSphere 8.0.3)

## Overview

Successfully planned and executed an in-place upgrade of a production VMware vCenter Server Appliance (VCSA) from **vSphere 7.0.3** to 
**vSphere 8.0.3** (latest supported release). The upgrade was performed following VMware/Broadcom best practices with comprehensive pre-upgrade 
validation, backup, rollback planning, and post-upgrade verification to ensure minimal downtime and service continuity.

---

# Environment

| Component      | Version                                |
| -------------- | -------------------------------------- |
| Platform       | VMware vSphere                         |
| Source Version | vCenter Server 7.0.3                     |
| Target Version | vCenter Server 8.0.3                  |
| Deployment     | VMware vCenter Server Appliance (VCSA) |
| Hypervisor     | VMware ESXi                            |
| Vendor         | Broadcom (VMware)                      |

---

# Objective

Upgrade the production vCenter Server to the latest supported vSphere 8 release while preserving:

* Inventory
* Cluster configuration
* Datacenters
* Hosts
* Virtual Machines
* Networking
* Storage configuration
* Roles & Permissions
* Historical data

---

# Pre-Upgrade Planning

Performed comprehensive health and compatibility checks before starting the upgrade.

### Infrastructure Validation

* Verified VMware compatibility matrix.
* Confirmed ESXi host compatibility.
* Validated third-party integration compatibility.
* Verified sufficient CPU, memory, and storage resources.

### Health Checks

* Checked vCenter appliance health.
* Verified service status.
* Confirmed no pending appliance reboot.
* Validated DNS forward and reverse lookup.
* Verified NTP synchronization.
* Confirmed network connectivity between source and target appliances.

### Certificate Validation

* Validated certificates.
* Confirmed no expired certificates.
* Verified no weak signature algorithms.

### Backup & Rollback Preparation

* Created File-Based Backup (VAMI backup).
* Took VM snapshot before upgrade.
* Prepared rollback procedure.
* Documented recovery plan in case of failure.

### Cluster Preparation

* Changed DRS mode from Fully Automated to Manual/Partially Automated.
* Verified required firewall ports (443 & 902).
* Reviewed VMware upgrade prerequisites.

---

# Upgrade Procedure

### Stage 1 – Deploy New vCenter Appliance

* Mounted VMware vCenter Server 8 installer ISO.
* Started VCSA Upgrade Wizard.
* Selected **Upgrade Existing vCenter**.
* Connected to the existing vCenter Server.
* Deployed the new appliance with temporary network settings.
* Validated deployment completion.

---

### Stage 2 – Data Migration

Migrated production data from the existing appliance, including:

* Inventory
* Configuration
* Users
* Permissions
* Historical data
* Performance data

The new appliance successfully assumed the identity of the existing production vCenter Server after migration.

---

# Validation

Performed comprehensive post-upgrade validation.

### Infrastructure Validation

* Verified all ESXi hosts were connected.
* Verified clusters were healthy.
* Confirmed datastores were accessible.
* Validated virtual machine inventory.
* Verified networking configuration.
* Checked Distributed Virtual Switch (DVS) status.
* Confirmed permissions and roles.
* Validated licensing.
* Verified vCenter services.

### Functional Testing

* Successfully logged into the vSphere Client.
* Confirmed VM management operations.
* Verified alarms and events.
* Checked monitoring functionality.
* Confirmed backup integrations.

---

# Rollback Strategy

Prepared rollback procedures before starting the upgrade.

* File-Based Backup available.
* Pre-upgrade VM snapshot created.
* Recovery steps documented.
* Rollback plan validated before maintenance window.

No rollback was required as the upgrade completed successfully.

---

# Outcome

* Successfully upgraded production vCenter Server from vSphere 7.x to vSphere 8.0.x.
* Preserved all production configurations and inventory.
* Completed upgrade with minimal service interruption.
* Verified successful migration of all production components.
* Improved platform supportability, security, and access to the latest VMware features.

---

# Technologies Used

* VMware vSphere
* VMware ESXi
* VMware vCenter Server Appliance (VCSA)
* VMware VAMI
* DRS
* DNS
* NTP
* Snapshot Management
* Infrastructure Upgrade Planning

---

# Key Learnings

* Thorough pre-upgrade validation significantly reduces upgrade risks.
* Verified backups and rollback plans are essential before production upgrades.
* DNS, certificates, and network connectivity should be validated prior to deployment.
* Post-upgrade validation is as important as the upgrade itself to ensure production stability.
* Following the recommended upgrade sequence (vCenter before ESXi hosts) helps maintain compatibility and minimizes operational risks.

---
