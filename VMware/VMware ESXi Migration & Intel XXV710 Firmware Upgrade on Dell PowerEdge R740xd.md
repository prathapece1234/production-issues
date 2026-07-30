# VMware ESXi Migration & Intel XXV710 Firmware Upgrade on Dell PowerEdge R740xd

## Project Overview

Performed a production maintenance activity to migrate a Dell PowerEdge R740xd host from the **HPE Customized VMware ESXi 8.0.3 image** 
to the **Dell Customized VMware ESXi 8.0.3 image**. After the hypervisor migration, completed firmware upgrades for all Dell-supported 
platform components using **Dell iDRAC/Lifecycle Controller**.

During post-upgrade validation, identified that one installed Intel XXV710 adapter was a **retail Intel OEM adapter** running an 
outdated firmware version. Since the adapter was outside Dell's firmware management scope, it was upgraded separately using Intel's 
official **NVM Update Utility** after validating compatibility with the VMware/Broadcom Hardware Compatibility Guide (HCL).

---

# Infrastructure

| Component        | Details                                     |
| ---------------- | ------------------------------------------- |
| Server           | Dell PowerEdge R740xd                       |
| Hypervisor       | VMware ESXi 8.0.3 (Build 25205845)          |
| Previous Image   | HPE Customized ESXi                         |
| Updated Image    | Dell Customized ESXi A10                    |
| Management       | Dell iDRAC / Lifecycle Controller           |
| Network Adapters | Dell OEM Intel XXV710 + Intel Retail XXV710 |
| Firmware Utility | Intel Ethernet NVM Update Utility v1.43.20  |

---

# Objectives

* Upgrade ESXi from HPE Customized Image to Dell Customized Image.
* Upgrade Dell platform firmware using Dell Lifecycle Controller.
* Validate hardware compatibility using VMware/Broadcom HCL.
* Upgrade Intel retail NIC firmware independently.
* Perform post-upgrade verification.

---

# Architecture

```text
                     VMware ESXi Host
                Dell PowerEdge R740xd
                        │
        ┌───────────────┴────────────────┐
        │                                │
 Dell OEM Components             Intel Retail NIC
 (BIOS, iDRAC, RAID, etc.)      XXV710 (Subdevice 0002)
        │                                │
 Updated via Dell                 Updated via Intel
 Lifecycle Controller           NVM Update Utility
```

---

# Phase 1 – ESXi Image Migration

Migrated the host from the HPE customized image to the Dell customized image.

## Command

```bash
esxcli software profile install \
-p DEL-ESXi_803.25205845-A10 \
-d /vmfs/volumes/<datastore>/ISO/VMware-VMvisor-Installer-8.0.0.update03-25205845.x86_64-Dell_Customized-A10.zip \
--no-hardware-warning \
--ok-to-remove
```

### Validation

* Successful ESXi image migration
* Host reboot completed
* Datastores detected
* VMkernel adapters operational
* Management connectivity restored
* Production networking verified

---

# Phase 2 – Platform Firmware Upgrade

Used **Dell iDRAC / Lifecycle Controller** to update all Dell-supported platform firmware used Dell repository manager (added base 
repository and connected this dell server and exported platform bootable iso) using this iso updated below components.

### Components Updated

* BIOS
* iDRAC
* PERC RAID Controller
* Storage Controller
* Backplane Firmware
* CPLD
* Power Supply Firmware
* Dell-supported NIC firmware

---



# Phase 3 – Hardware Verification

Verified storage controller before firmware validation.

```bash
esxcli hardware pci list | grep -A20 -Ei "RAID|SAS|MegaRAID|PERC|LSI|Broadcom"
```

Verified Intel NVM utility installation.

```bash
esxcli software vib list | grep -i nvmupdate
```

---

# Phase 4 – Install Intel NVM Update Utility

Installed Intel's official firmware update utility.

```bash
esxcli software vib install \
-v /vmfs/volumes/datastore1/INT_bootbank_nvmupdaten64e_1.43.20.0-1OEM.800.1.0.20613240.vib \
--no-sig-check
```

---

# Phase 5 – Firmware Inventory

Collected NIC inventory before updating.

```bash
/opt/nvmupdaten64e/bin/nvmupdaten64e \
-i \
-l \
-o /tmp/inventory.xml \
-c nvmupdate.cfg
```

## Inventory Result

### Dell OEM Adapter

| Property  | Value             |
| --------- | ----------------- |
| Subdevice | 0009              |
| Firmware  | NVM 9.80 (9.50)   |
| Status    | Already Supported |

No firmware update required.

---

### Intel Retail Adapter

| Property  | Current  |
| --------- | -------- |
| Vendor    | Intel    |
| Device    | XXV710   |
| Subdevice | 0002     |
| ETrackID  | 80003D05 |
| NVM       | 6.80     |
| CIVD      | 1.2007.0 |
| PXE       | 1.1.2    |
| EFI       | 3.3.37   |

Inventory reported:

```text
NVM Update : Update Required
OROM Update : Update Required
```

Target Firmware:

| Component | Version                             |
| --------- | ----------------------------------- |
| ETrackID  | 8000FE60                            |
| NVM Image | XXV710DA2_9p55_CFGID12p0_OEMGEN.bin |
| PXE       | 1.1.45                              |
| EFI       | 5.0.22                              |
| CIVD      | 1.3862.0                            |

---

# Phase 6 – Firmware Upgrade

Created firmware backup and upgraded the Intel XXV710 adapter.

```bash
/opt/nvmupdaten64e/bin/nvmupdaten64e \
-u \
-b \
-c nvmupdate.cfg \
-l \
-o /tmp/update_results.xml
```

### Operations Performed

* Firmware backup
* Flash update
* NVM verification
* Flash verification
* PXE ROM update
* EFI ROM update
* Option ROM verification
* Device verification

Update completed successfully.

Console output confirmed:

```text
Flash update successful.
OROM update successful.
Device update successful.
A reboot is required to complete the update process.
```

---

# Phase 7 – Reboot & Validation

Rebooted the ESXi host to activate the updated NIC firmware.

Post-reboot validation included:

```bash
esxcli network nic list
```

```bash
esxcli network nic get -n vmnic0
esxcli network nic get -n vmnic1
esxcli network nic get -n vmnic2
esxcli network nic get -n vmnic3
```

Verified:

* NIC firmware version
* Driver version
* Link status
* VMkernel connectivity
* Storage connectivity
* Production network communication

---

# Firmware Summary

| Component              | Before         | After               |
| ---------------------- | -------------- | ------------------- |
| ESXi Image             | HPE Customized | Dell Customized A10 |
| BIOS                   | Previous       | Latest Supported    |
| iDRAC                  | Previous       | Latest Supported    |
| RAID Controller        | Previous       | Latest Supported    |
| Dell Platform Firmware | Previous       | Latest Supported    |
| Intel XXV710 NVM       | 6.80           | 9.55                |
| PXE                    | 1.1.2          | 1.1.45              |
| EFI                    | 3.3.37         | 5.0.22              |
| CIVD                   | 1.2007.0       | 1.3862.0            |

---

# Technical Challenge

The host contained two different Intel XXV710 adapters:

* **Dell OEM Adapter (Subdevice 0009)** – Already running a Dell-supported firmware version and managed through Dell firmware
  repositories.
* **Intel Retail Adapter (Subdevice 0002)** – Running an older Intel firmware version and not supported by Dell Lifecycle Controller for
  firmware updates.

To maintain VMware compatibility:

* Verified firmware compatibility using the VMware/Broadcom Hardware Compatibility Guide.
* Installed Intel's official NVM Update Utility.
* Performed firmware inventory and compatibility validation.
* Backed up the existing firmware before upgrading.
* Successfully upgraded the Intel retail adapter from **NVM 6.80** to **NVM 9.55**.
* Verified the firmware after reboot.

---

# Outcome

* Successfully migrated VMware ESXi from the HPE Customized Image to the Dell Customized Image.
* Upgraded Dell platform firmware using Dell iDRAC/Lifecycle Controller.
* Identified a mixed OEM hardware configuration during validation.
* Upgraded the Intel retail XXV710 adapter independently using Intel's official firmware utility.
* Verified firmware compatibility with the VMware/Broadcom Hardware Compatibility Guide.
* Completed firmware validation and production health checks successfully.
* Restored the ESXi host to production without storage or network issues.

---

# Technologies & Skills

* VMware ESXi 8.0.3
* Dell PowerEdge R740xd
* Dell iDRAC & Lifecycle Controller
* VMware Image Profile Management
* Intel Ethernet NVM Update Utility
* Intel XXV710 Firmware Management
* VMware/Broadcom Hardware Compatibility Guide (HCL)
* Enterprise Firmware Lifecycle Management
* Hardware Compatibility Validation
* Production Infrastructure Maintenance
* Change & Release Management
* Linux CLI & ESXi Shell
* Enterprise Server Administration
