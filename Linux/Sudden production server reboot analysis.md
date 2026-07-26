**Production Incident: Root Cause Analysis of Linux Kernel Panic on RHEL 8 Production Server**

## Overview

A production gateway server (**attmspligw2**) unexpectedly crashed after running continuously for **575 days**. The incident resulted in an 
unplanned reboot, impacting production services.

The initial symptoms suggested a hardware failure or operating system instability. A detailed investigation involving kernel logs, crash analysis, 
Red Hat documentation, and kernel version verification revealed that the server encountered a **known Red Hat Enterprise Linux kernel bug** 
affecting the cgroup subsystem.

After confirming the issue with Red Hat's published bug reports, the production server was upgraded to the fixed kernel version, eliminating the 
known defect.

---

## Environment

| Component              | Details                      |
| ---------------------- | ---------------------------- |
| Operating System       | Red Hat Enterprise Linux 8.4 |
| Kernel Version         | 4.18.0-305.el8.x86_64        |
| Server                 | attmspligw2                  |
| Server Role            | Production Gateway           |
| Uptime Before Incident | 575 Days 21 Hours            |
| Environment            | Production                   |

---

## Problem Statement

The production server unexpectedly crashed and rebooted automatically.

Incident Details:

| Parameter     | Value                        |
| ------------- | ---------------------------- |
| Incident Date | 10 October 2025              |
| Incident Time | 07:10:04 UTC                 |
| Server        | attmspligw2                  |
| Impact        | Unexpected Production Reboot |

The objective was to determine whether the incident was caused by:

* Hardware failure
* Memory corruption
* Kernel defect
* Driver issue
* High CPU utilization
* Operating system bug

---

## Requirements

* Identify the cause of the unexpected reboot.
* Analyze kernel panic information.
* Determine whether the issue was hardware or software related.
* Verify whether the issue matched any known Red Hat defects.
* Implement a permanent fix.

---

## Investigation

### Step 1 – Verify System Crash Information

Collected crash details from the system logs.

Reviewed:

```bash
journalctl -k

dmesg

vmcore
```

The kernel panic showed the following message:

```text
kernel BUG at lib/list_debug.c:50!
```

This confirmed that the reboot was triggered by a kernel panic rather than a hardware reset or power failure.

---

### Step 2 – Analyze Kernel Panic

Further analysis identified the following corruption:

```text
list_del corruption

LIST_POISON2
(dead000000000200)
```

The panic occurred while the Linux kernel attempted to remove an already corrupted linked list entry.

The affected worker process was:

```text
kworker/7:2
```

---

### Step 3 – Review Kernel Call Trace

The kernel call trace pointed to:

```text
css_release_work_fn()
```

This function belongs to the Linux **cgroup subsystem**, which manages resource control groups used by system services and applications.

The crash occurred during cleanup of kernel-managed objects.

---

### Step 4 – Investigate Possible Causes

Several possibilities were considered during the investigation:

* Hardware memory failure
* Filesystem corruption
* Third-party kernel module
* Driver instability
* CPU overload
* Known kernel defects

Hardware monitoring showed no indication of:

* ECC memory errors
* Disk failures
* Filesystem corruption
* Hardware alerts

Although CPU utilization was high at the time of the incident, no evidence suggested that resource usage alone caused the crash.

---

### Step 5 – Correlate with Red Hat Documentation

Compared the observed kernel version and panic signature with Red Hat knowledge articles.

The panic matched a documented Red Hat issue involving:

* `list_del` corruption
* `LIST_POISON2`
* `css_release_work_fn()`
* RHEL 8.4 kernel **4.18.0-305**

Red Hat identified this as a kernel bug affecting cgroup cleanup under specific workload conditions.

The published fix was included in a later kernel release.

---

## Root Cause

The production server was running **RHEL 8.4 kernel 4.18.0-305.el8.x86_64**, which contains a known kernel defect affecting the Linux cgroup 
subsystem.

During cgroup cleanup, the kernel encountered corruption in an internal linked list (`list_del` corruption), triggering a kernel panic to prevent 
further memory corruption.

Although high CPU activity was observed at the time of the incident, the underlying cause was a software defect in the kernel rather than hardware 
failure or application instability.

---

## Resolution

Verified the corrected kernel version published by Red Hat.

Performed:

* Kernel package upgrade
* Production maintenance window
* Controlled server reboot
* Kernel verification after startup

Upgraded to:

```text
Kernel Version

4.18.0-305.12.1.el8_4
(or later)
```

The reboot was required to load the updated kernel.

---

## Validation

After the maintenance activity:

Verified:

* Updated kernel loaded successfully.
* Production services started normally.
* No kernel panic events observed.
* Applications operating normally.
* System remained stable.

The server was monitored for **48 hours** after the upgrade.

No further kernel panic events occurred.

---

## Outcome

* Successfully identified the root cause of the unexpected production reboot.
* Confirmed the incident matched a documented Red Hat kernel defect.
* Eliminated the software bug by upgrading the production kernel.
* Restored production stability.
* Prevented recurrence through proactive kernel maintenance.

---

## Root Cause Analysis (RCA)

| Component      | Status                                                                        |
| -------------- | ----------------------------------------------------------------------------- |
| Hardware       | Healthy                                                                       |
| Memory         | Healthy                                                                       |
| Filesystem     | Healthy                                                                       |
| Applications   | Healthy                                                                       |
| CPU            | High utilisation observed                                                     |
| Kernel         | Known software defect                                                         |
| Red Hat Bug    | Confirmed                                                                     |
| **Root Cause** | Known RHEL 8.4 kernel bug causing `list_del` corruption during cgroup cleanup |

---

## Technologies Used

* Red Hat Enterprise Linux 8
* Linux Kernel
* Kernel Panic Analysis
* `journalctl`
* `dmesg`
* `vmcore`
* cgroups
* Red Hat Knowledge Base
* Kernel Lifecycle Management
* Production Patch Management
* Root Cause Analysis

---

## Key Learning

Unexpected server reboots are not always caused by failing hardware or resource exhaustion. Kernel panic analysis, combined with vendor d
ocumentation, is essential to distinguish between environmental issues and operating system defects. Correlating panic signatures with Red Hat's 
published bug database enabled a targeted remediation through a kernel upgrade, avoiding unnecessary hardware replacement and improving long-term 
production stability.

