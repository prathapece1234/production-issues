# VMware ESXi Host Client GUI Failure Due to Storage Metadata Deadlock

## Overview

Resolved a production VMware ESXi management issue where the **ESXi Host Client Web GUI (`/ui`) became inaccessible** despite the host 
remaining operational. Administrators experienced HTTP 503 errors and session disconnects immediately after authentication, while SSH and 
DCUI continued to function normally.

A detailed investigation identified a storage metadata deadlock involving the running vCenter Server virtual machine, which caused the 
`hostd` management service to become blocked and prevented the web management interface from responding.

---

# Environment

| Component          | Details                                |
| ------------------ | -------------------------------------- |
| Platform           | VMware ESXi                            |
| Management Service | hostd                                  |
| Web Proxy          | rhttpproxy                             |
| Virtual Machine    | VMware vCenter Server Appliance (VCSA) |
| Storage            | Dell PowerVault ME5 SAN                |
| Access Methods     | ESXi Host Client, SSH, DCUI            |

---

# Problem Statement

The ESXi Host Client (`https://<esxi-host>/ui`) became unavailable immediately after successful user authentication.

Observed symptoms included:

* HTTP 503 Service Unavailable errors.
* Browser loading indefinitely.
* User sessions disconnecting immediately after login.
* SSH access remained functional.
* DCUI remained accessible.
* Running virtual machines continued operating without interruption.

---

# Investigation

Performed a systematic investigation across the VMware management stack.

## Reviewed Hostd Logs

Examined the management service logs.

```bash
tail -f /var/log/hostd.log
```

Observed repeated timeout exceptions:

```text
Timed out writing HTTP response.
Write timeout after approximately 50000ms.
Ill-formed header on stream.
```

These errors indicated that `hostd` worker threads were unable to complete HTTP requests.

---

## Identified Storage Metadata Failures

Further log analysis revealed repeated failures while retrieving metadata for the running VMware vCenter Server virtual machine.

Example:

```text
File failed to get objectId
Operation not supported (11)
```

The failures occurred during VM configuration file (`.vmx`) metadata access.

---

## Verified Storage Health

Validated the VMFS datastore and SAN connectivity.

```bash
esxcli storage vmfs extent list
```

Confirmed:

* All VMFS datastores were accessible.
* No APD (All Paths Down) condition.
* No PDL (Permanent Device Loss).
* No storage latency observed.

This eliminated physical storage as the root cause.

---

## Verified Running Virtual Machines

Confirmed that the vCenter Server virtual machine remained healthy.

```bash
esxcli vm process list
```

Verified:

* VM running normally.
* World ID active.
* No guest operating system impact.

---

## Validated Storage Lock Ownership

Inspected VMFS file locking information.

```bash
vmkfstools -D <vcenter.vmx>
```

Observed:

* Exclusive Read/Write lock present.
* Lock owner UUID differed from the current host identity.

This indicated a stale metadata ownership condition.

---

# Root Cause Analysis (RCA)

The investigation determined that the issue was caused by a **storage metadata deadlock** affecting the running vCenter Server virtual 
machine.

During routine inventory and datastore validation, `hostd` attempted to retrieve metadata for the VCSA `.vmx` configuration file. A stale 
VMFS lock ownership reference caused the metadata request to block indefinitely.

As additional management requests accumulated, the available `hostd` worker threads became exhausted, preventing HTTP responses from 
being returned to `rhttpproxy`.

Although the management plane was impacted, the ESXi kernel, virtual machines, SSH service, and DCUI remained fully operational.

---

# Resolution

## Step 1 – Validate Storage Layer

Confirmed datastore accessibility and storage path health.

```bash
esxcli storage vmfs extent list
```

Result:

* Storage online.
* No path failures.
* No APD or PDL events.

---

## Step 2 – Verify Running VM

Confirmed the VMware vCenter Server Appliance remained operational.

```bash
esxcli vm process list
```

Recorded the active World ID for verification.

---

## Step 3 – Refresh VM Metadata

Retrieved the VM identifier.

```bash
vim-cmd vmsvc/getallvms
```

Reloaded the virtual machine configuration without powering off the guest.

```bash
vim-cmd vmsvc/reload <VMID>
```

This refreshed the runtime metadata within the ESXi management layer.

---

## Step 4 – Restart Management Services

Restarted the management agents to clear blocked worker threads.

Restart `hostd`:

```bash
/etc/init.d/hostd restart
```

Restart the reverse proxy:

```bash
/etc/init.d/rhttpproxy restart
```

> **Note:** In this production incident, the blocked `hostd` process was terminated before restarting the service to recover from the 
deadlocked state.

```bash
kill -9 $(ps | grep hostd | awk '{print $1}')
```

without this gui will show failed to load host summary.

Followed by:

```bash
/etc/init.d/hostd start
```

```bash
/etc/init.d/rhttpproxy restart
```

---

# Validation

Verified that the management services were healthy.

```bash
/etc/init.d/hostd status
```

```bash
/etc/init.d/rhttpproxy status
```

Confirmed:

* ESXi Host Client accessible.
* Authentication successful.
* No unexpected session disconnects.
* HTTP responses returned normally.
* Virtual machines remained operational.
* No further timeout exceptions in `hostd.log`.

---

# Outcome

* Restored full ESXi Host Client functionality.
* Eliminated HTTP timeout and session disconnect issues.
* Cleared blocked management service worker threads.
* Resolved storage metadata synchronization issue without affecting production virtual machines.
* Avoided unnecessary host reboot or virtual machine downtime.
* Successfully restored normal management operations while maintaining production availability.

---

# Technologies Used

* VMware ESXi
* VMware Host Client
* hostd
* rhttpproxy
* VMware vCenter Server Appliance (VCSA)
* VMFS
* Dell PowerVault ME5 SAN
* SSH
* Linux CLI
* VMware ESXi Shell

---

# Key Learnings

* ESXi management plane failures do not necessarily impact running virtual machines.
* `hostd` log analysis is essential for diagnosing Host Client issues.
* Storage metadata inconsistencies can cause management service deadlocks even when storage hardware is healthy.
* VMFS lock validation helps distinguish logical metadata issues from physical storage failures.
* Reloading VM metadata and restarting management services can restore functionality without requiring an ESXi host reboot.
* Always validate storage health before restarting management services to avoid masking underlying infrastructure issues.

---
