# Production VMware ESXi Firmware & Hypervisor Upgrade

## Project Summary

Performed firmware lifecycle management and VMware ESXi patching for production HPE ProLiant and Dell PowerEdge servers hosting critical virtual machines.

The activity included upgrading server firmware, BIOS, management controllers (iLO/iDRAC), NIC firmware, VMware ESXi image, and validating the virtualization environment after maintenance.

The objective was to maintain vendor support, improve hardware stability, resolve driver compatibility issues, and keep the infrastructure aligned with VMware and hardware vendor recommendations.

---

## Environment

### VMware

- VMware ESXi 8.0.3
- HPE Customized ESXi Image
- Dell Customized ESXi Image

### Hardware

#### HPE

- HPE ProLiant Servers
- Broadcom BCM57414 NetXtreme-E 10/25Gb NIC
- iLO Management

#### Dell

- Dell PowerEdge R740xd
- Intel XXV710 25GbE NIC
- iDRAC Management

---

## Components Upgraded

### HPE Servers

- VMware ESXi Build
- HPE Custom Add-On
- BIOS
- iLO Firmware
- Broadcom NIC Firmware
- Broadcom NIC Driver

### Dell Servers

- VMware ESXi Build
- BIOS
- iDRAC Firmware
- Intel NIC Firmware
- Intel NIC Driver
- PERC Controller Firmware

---

## Pre-Maintenance Activities

Before starting maintenance:

- Verified VM backups.
- Confirmed rollback procedures.
- Scheduled maintenance window.
- Downloaded the latest Service Pack for ProLiant (SPP) and Dell firmware packages.
- Verified VMware Compatibility Guide.
- Collected current firmware and driver inventory.
- Verified hardware health.

---

## Maintenance Procedure

### 1. Place ESXi Host into Maintenance Mode

- Migrated virtual machines using vMotion.
- Shut down VMs where migration was not possible.
- Confirmed host entered Maintenance Mode successfully.

---

### 2. HPE Firmware Upgrade

Performed firmware upgrade using HPE Service Pack for ProLiant (SPP).

Upgrade process:

- Mounted SPP ISO through iLO Virtual Media.
- Booted the server using Virtual CD/DVD.
- Allowed SPP to inventory server hardware.
- Updated:

  - BIOS
  - iLO
  - Smart Array Controller
  - Broadcom NIC Firmware
  - Storage Firmware
  - Other supported firmware components

The server rebooted automatically after firmware installation.

---

### 3. Dell Firmware Upgrade

Performed firmware upgrades using Dell Lifecycle Controller / Bootable ISO.

Updated:

- BIOS
- iDRAC
- PERC Controller
- Intel NIC Firmware

Rebooted the server after firmware installation.

---

### 4. VMware ESXi Upgrade

After firmware updates:

- Installed the latest OEM Customized ESXi Image.
- Updated ESXi base image.
- Updated OEM components.
- Applied the latest VMware patches.

---

### 5. NIC Driver Upgrade

Verified VMware Compatibility Guide.

Performed NIC driver upgrades only where required.

Examples:

#### Broadcom BCM57414

- Driver upgraded
- Firmware upgraded

#### Intel XXV710

- Driver upgraded
- Firmware upgraded

---

### 6. Reboot

Rebooted the ESXi host after completing upgrades.

Verified:

- ESXi Build Version
- BIOS Version
- Firmware Versions
- Driver Versions

---

## Post-Upgrade Validation

Performed infrastructure validation after maintenance.

Validated:

- ESXi Host Health
- Network Connectivity
- Storage Connectivity
- Datastore Accessibility
- vMotion
- VM Power-on
- Management Connectivity
- iLO / iDRAC Health
- Hardware Sensors
- VMware Services

Reviewed:

- ESXi Logs
- iLO Integrated Management Log (IML)
- iDRAC Lifecycle Logs

No hardware or firmware errors were detected.

---

## Result

Successfully upgraded:

### HPE

- ESXi Build
- HPE Custom Add-On
- BIOS
- iLO Firmware
- Broadcom NIC Firmware
- Broadcom NIC Driver

<img width="1085" height="386" alt="image" src="https://github.com/user-attachments/assets/850ce8d7-2e00-440b-9eb3-dbfe7cbf29e9" />

<img width="1337" height="658" alt="image" src="https://github.com/user-attachments/assets/c28f4388-c42a-492f-9c5f-24ba491822bb" />

### Dell

- ESXi Build
- BIOS
- iDRAC Firmware
- Intel NIC Firmware
- Intel NIC Driver
- PERC Firmware

<img width="965" height="626" alt="image" src="https://github.com/user-attachments/assets/c21bde9b-ce26-46c9-bbe1-56c9117986a0" />


All virtual machines resumed normal operation after maintenance.

---

## Benefits

- Improved hardware stability.
- Updated VMware security patches.
- Vendor-supported firmware levels.
- Improved NIC compatibility.
- Reduced risk of hardware-related incidents.
- Maintained VMware Compatibility Guide compliance.

---

## Technologies Used

- VMware ESXi 8.0.3
- VMware vCenter
- HPE ProLiant
- Dell PowerEdge R740xd
- HPE iLO
- Dell iDRAC
- HPE Service Pack for ProLiant (SPP)
- Dell Lifecycle Controller
- VMware OEM Customized Images
- Broadcom BCM57414 NIC
- Intel XXV710 NIC
- VMware vMotion
- Firmware Lifecycle Management
- Infrastructure Patching

---

## Key Learnings

- Follow firmware upgrades before applying VMware ESXi patches to maintain hardware compatibility.
- Use OEM-customized ESXi images to ensure proper driver and firmware integration.
- Validate firmware and driver compatibility using the VMware Compatibility Guide before upgrades.
- Always place hosts in Maintenance Mode and migrate workloads before performing infrastructure maintenance.
- Perform comprehensive post-upgrade validation, including networking, storage, vMotion, and hardware health checks, before returning the host to production.
