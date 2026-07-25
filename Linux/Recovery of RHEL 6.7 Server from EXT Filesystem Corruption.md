Recovery of RHEL 6.7 Server from EXT Filesystem Corruption Using Rescue Mode

## Overview

A legacy **RHEL 6.7** server (**192.168.149.7**) became inaccessible after filesystem corruption prevented the operating system from booting 
successfully. During startup, the server entered **Maintenance Mode** and displayed a filesystem inconsistency error, indicating that manual 
filesystem repair was required.

The server was booted into rescue mode, the LVM volume groups were activated, and the affected EXT filesystem was repaired using `fsck`. The utility 
detected and repaired filesystem inconsistencies, allowing the server to boot normally without requiring an operating system reinstallation.

---

## Environment

| Component | Details |
|-----------|---------|
| Operating System | Red Hat Enterprise Linux 6.7 |
| Filesystem | EXT (ext3/ext4) |
| Storage | LVM |
| Server | 192.168.149.7 |

---

## Problem Statement

The server became inaccessible after a filesystem inconsistency prevented the operating system from completing the boot process.

During boot, the console displayed the following message:

```text
UNEXPECTED INCONSISTENCY; RUN fsck MANUALLY.
```

The system subsequently entered **Maintenance Mode**, preventing users and applications from accessing the server.

---

## Investigation

Booted the server into rescue mode.

Activated all LVM volume groups.

```bash
vgchange -ay
```

Verified the available logical volumes.

```bash
lvs
```

Identified the affected filesystem and executed a filesystem consistency check.

```bash
fsck -fy /dev/<VG_NAME>/<LV_NAME>
```

During the repair process, `fsck` detected filesystem inconsistencies and dirty filesystem metadata, repaired the affected structures, and restored 
filesystem consistency.

---

## Root Cause

The server experienced filesystem corruption on the EXT filesystem, preventing the operating system from mounting the root filesystem during boot.

As a result, the system entered Maintenance Mode and required manual filesystem repair before normal startup could continue.

---

## Resolution

Performed recovery from rescue mode.

Activated all LVM volume groups.

```bash
vgchange -ay
```

Executed filesystem repair on the affected logical volume.

```bash
fsck -fy /dev/<VG_NAME>/<LV_NAME>
```

The repair utility automatically corrected the detected filesystem inconsistencies and repaired damaged filesystem metadata.

After the repair completed successfully, the server was rebooted.

```bash
reboot
```

---

## Validation

Verified:

- Filesystem repaired successfully.
- Root filesystem mounted correctly.
- Server booted without entering Maintenance Mode.
- SSH login restored.
- Applications and services started successfully.
- No further filesystem consistency errors were reported.

---

## Outcome

- Successfully recovered the server from filesystem corruption.
- Restored normal server operation without requiring OS reinstallation.
- Recovered filesystem consistency using `fsck`.
- Restored application availability.

Following the recovery, the application team was advised to take a complete backup of the server because of the legacy operating system (RHEL 6.7). 
They were also informed that future filesystem corruption on an aging platform may not always be recoverable and that planning an OS upgrade would 
reduce long-term operational risk.

---

## Technologies Used

- Red Hat Enterprise Linux 6.7
- EXT3/EXT4 Filesystem
- LVM
- Rescue Mode
- fsck
- Linux System Administration

---

## Key Learning

Filesystem corruption on EXT filesystems can prevent a Linux server from booting and cause it to enter Maintenance Mode. Using rescue mode to 
activate LVM volumes and perform an offline `fsck` repair is the recommended recovery approach. For legacy systems, maintaining regular backups 
and planning operating system upgrades are essential to reduce the impact of future filesystem failures.

