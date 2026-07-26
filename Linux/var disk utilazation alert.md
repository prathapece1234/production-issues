**Production Incident: Resolving High `/var` Disk Utilization Caused by Open Deleted Files**

## Overview

A production monitoring alert reported that the **`/var`** filesystem on the application server had reached the warning threshold, with disk 
utilization at **80%**. Initially, the alert appeared to be caused by excessive log generation, which is a common reason for `/var` filesystem growth.

A systematic investigation was performed to identify the actual disk consumers. While log files, mail queues, and temporary files appeared normal, 
further analysis revealed that a running process (`netfmt`) was still holding multiple deleted files open. These deleted files continued consuming 
disk space until the process was restarted.

Restarting the affected process released the file handles immediately, recovering over **32 GB** of disk space without requiring a server reboot.

---

## Environment

| Component            | Details                  |
| -------------------- | ------------------------ |
| Operating System     | Red Hat Enterprise Linux |
| Environment          | Production               |
| Application Process  | netfmt                   |
| Monitored Filesystem | `/var`                   |
| Monitoring Tool      | OpsRamp                  |

---

## Problem Statement

The monitoring platform generated a warning indicating high disk utilization on the `/var` filesystem.

Filesystem status:

| Filesystem |    Total |     Used |     Free | Utilization |
| ---------- | -------: | -------: | -------: | ----------: |
| `/var`     | 49.99 GB | 39.49 GB | 10.49 GB |         80% |

The objective was to identify the source of disk consumption and restore available space before the filesystem reached a critical level.

---

## Requirements

* Identify what was consuming space under `/var`.
* Verify whether the issue was caused by log growth or another process.
* Recover disk space safely.
* Restore the filesystem to a healthy state.

---

## Investigation

### Step 1 – Verify Filesystem Utilization

Confirmed the alert using:

```bash
df -h /var
```

The `/var` partition showed approximately **80% utilization**, matching the monitoring alert.

---

### Step 2 – Review Log Files

Since `/var` commonly stores application and system logs, the initial investigation focused on log growth.

Reviewed:

* `/var/log`
* Application log directories
* Log rotation status

Verified using:

```bash
du -sh /var/log/*
```

**Result**

* No unusually large log files were found.
* Log rotation was functioning normally.
* Log usage did not explain the reported disk consumption.

The investigation moved to the next possibility.

---

### Step 3 – Verify Mail Queue and Temporary Files

Checked other common causes of `/var` growth.

Reviewed:

* Mail queue
* Temporary files
* Spool directories
* Application cache

Examples:

```bash
mailq

du -sh /var/spool/*
```

**Result**

* Mail queue was normal.
* No abnormal spool growth.
* Temporary directories were within expected limits.

At this stage, the visible filesystem usage still did not account for the missing space.

---

### Step 4 – Check for Open Deleted Files

Since the filesystem usage remained unexplained, the investigation focused on processes holding deleted files open.

Executed:

```bash
lsof | grep deleted
```

The output revealed multiple deleted files still opened by the **netfmt** process.

Example:

```text
netfmt
Raw-slices/sys_mon_slice_rawdmp.*
(deleted)
```

Although these files had already been deleted from the filesystem, they remained allocated because the running process still had active file 
descriptors.

The total space occupied by these deleted files was approximately **32.24 GB**.

---

## Root Cause

The **netfmt** application continued holding deleted raw dump files open after they had been removed from the filesystem.

Because Linux only releases disk space after all file handles are closed, the deleted files continued occupying approximately **32 GB** of storage 
even though they were no longer visible in the directory.

The high `/var` utilization was therefore caused by **open deleted files retained by the running process**, not by active log files or application 
data.

---

## Resolution

Restarted the affected **netfmt** process to release the open file descriptors.

After the restart:

* Open deleted files were released.
* Disk blocks were returned to the filesystem.
* `/var` utilization dropped immediately.

No reboot was required.

---

## Validation

Verified after the process restart:

```bash
lsof | grep deleted
```

**Result**

* No deleted files remained open.
* Approximately **32 GB** of disk space was recovered.
* `/var` utilization returned to normal.
* Monitoring alerts cleared automatically.

---

## Outcome

* Successfully identified the actual cause of disk utilization.
* Avoided unnecessary log cleanup and filesystem maintenance.
* Recovered over **32 GB** of disk space.
* Cleared monitoring alerts without downtime.
* Restored normal filesystem utilization.

---

## Root Cause Analysis (RCA)

| Component            | Status                                              |
| -------------------- | --------------------------------------------------- |
| Filesystem           | Healthy                                             |
| Log Files            | Normal                                              |
| Mail Queue           | Normal                                              |
| Spool Directories    | Normal                                              |
| Temporary Files      | Normal                                              |
| Application Process  | Holding deleted files open                          |
| Disk Space Recovered | ~32.24 GB                                           |
| **Root Cause**       | Open deleted files retained by the `netfmt` process |

---

## Technologies Used

* Red Hat Enterprise Linux
* Filesystem Administration
* Process Management
* `lsof`
* `df`
* `du`
* OpsRamp Monitoring
* Linux Troubleshooting
* Production Incident Management
* Root Cause Analysis

---

## Key Learning

High disk utilization is not always caused by visible files. In Linux, deleting a file does not immediately free disk space if a running process 
still holds an open file descriptor. When standard checks such as log directories, spool areas, and temporary files do not explain filesystem 
growth, inspecting **open deleted files** using `lsof` is a critical troubleshooting step. This approach can recover significant disk space without 
deleting additional files or rebooting the server.
