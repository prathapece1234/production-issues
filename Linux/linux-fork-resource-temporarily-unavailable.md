**Production Incident: Analysis of "Resource Temporarily Unavailable" During Concurrent Script Execution**

## Overview

During application testing, users reported that application scripts intermittently failed to start on the production server with the error 
**"Resource temporarily unavailable."** Initially, the issue appeared to indicate an operating system or filesystem problem.

A detailed investigation was carried out to determine whether the failure originated from the Linux operating system, filesystem, or application. 
The analysis revealed that the server itself was healthy and the issue occurred only when multiple resource-intensive scripts were executed 
simultaneously, causing temporary resource exhaustion during process creation.

---

## Environment

| Component        | Details                    |
| ---------------- | -------------------------- |
| Operating System | Red Hat Enterprise Linux   |
| Environment      | Production                 |
| Application      | Custom Application Scripts |
| Server           | uspmrw2                    |

---

## Problem Statement

The application team reported intermittent failures while executing application scripts.

Observed error:

```text
bash: fork: retry: Resource temporarily unavailable
bash: fork: Interrupted system call
```

The issue prevented new application processes from starting during peak execution periods.

---

## Requirements

* Verify operating system health.
* Determine whether the issue was related to memory, filesystem, or application.
* Identify the cause of the `fork()` failure.
* Recommend a permanent solution.

---

## Investigation

### Step 1 – Verify Server Health

Checked overall system utilization.

```bash
top
free -h
vmstat 1 5
uptime
```

**Result**

* CPU utilization within normal limits.
* No abnormal load average.
* Filesystem healthy.
* No hardware-related issues.

---

### Step 2 – Verify Filesystem

Confirmed that disk space was not contributing to the issue.

```bash
df -h
```

The filesystem had sufficient free space, eliminating storage as the cause.

---

### Step 3 – Reproduce the Issue

Executed the application script.

```bash
./run.sh
```

Observed:

```text
bash: fork: retry: Resource temporarily unavailable
bash: fork: Interrupted system call
```

The error occurred only when several application scripts were started simultaneously.

After reducing the number of concurrent executions, the same script completed successfully without any changes to the operating system.

---

### Step 4 – Analyze Resource Usage

Reviewed process creation behaviour during concurrent execution.

The Linux `fork()` system call temporarily failed because the operating system could not allocate sufficient resources to create additional child 
processes while multiple scripts were starting simultaneously.

Once the workload reduced, new processes were created normally.

---

## Root Cause

The server was operating normally throughout the incident.

The issue was caused by **multiple application scripts being launched simultaneously**, which temporarily exhausted available memory/resources 
required for the Linux `fork()` system call.

This resulted in the operating system returning:

```text
Resource temporarily unavailable
```

The issue was related to application workload concurrency rather than an operating system fault.

---

## Resolution

* Verified server CPU, memory, filesystem, and load.
* Confirmed there were no operating system or hardware issues.
* Reproduced the issue under concurrent execution.
* Identified temporary resource exhaustion during process creation.
* Recommended avoiding simultaneous execution of multiple resource-intensive scripts.
* Suggested staggering script execution or increasing system memory if higher concurrency is required.

---

## Validation

After limiting concurrent script execution:

* Scripts executed successfully.
* No further `fork()` failures were observed.
* Application processes started normally.
* Server resources remained stable.

---

## Outcome

* Successfully ruled out operating system and filesystem issues.
* Identified application concurrency as the trigger.
* Prevented unnecessary operating system changes.
* Recommended workload optimization for stable execution under load.

---

## Root Cause Analysis (RCA)

| Component        | Status                                                                              |
| ---------------- | ----------------------------------------------------------------------------------- |
| Operating System | Healthy                                                                             |
| CPU              | Healthy                                                                             |
| Memory           | Temporary pressure during concurrent execution                                      |
| Filesystem       | Healthy                                                                             |
| Application      | Multiple concurrent script executions                                               |
| **Root Cause**   | Temporary resource exhaustion during `fork()` caused by concurrent script execution |

---

## Technologies Used

* Red Hat Enterprise Linux
* Linux Process Management
* Shell Scripting
* Process Monitoring
* Memory Management
* Linux Troubleshooting
* Production Incident Management

---

## Key Learning

The Linux `fork()` error **"Resource temporarily unavailable"** does not always indicate an operating system failure. It can occur when an 
application attempts to create more processes than the system can temporarily support due to memory or process resource constraints. In this 
incident, the server was healthy, and the issue was resolved by analysing workload patterns rather than making unnecessary system changes. 
Proper workload scheduling and concurrency control are essential for stable application execution.

\
