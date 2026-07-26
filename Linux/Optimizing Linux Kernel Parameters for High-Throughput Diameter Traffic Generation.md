**Production Performance Tuning: Optimizing Linux Kernel Parameters for High-Throughput Diameter Traffic Generation**

## Overview

During performance testing of a Diameter-based application using **Seagull**, the R&D team encountered repeated transmission failures while 
generating high-volume traffic. The traffic generator was unable to sustain the required throughput, causing incomplete message transmission and 
failed test execution.

The initial assumption was that the issue was related to the Seagull application itself. However, after analysing the operating system and 
networking stack, it became evident that the Linux kernel was operating with default networking and resource limits that were insufficient for 
high-volume traffic generation.

By tuning the Linux kernel networking parameters, socket buffer sizes, and file descriptor limits, the servers successfully handled the required 
traffic load and the transmission errors were eliminated.

---

## Environment

| Component         | Details                                         |
| ----------------- | ----------------------------------------------- |
| Operating System  | Red Hat Enterprise Linux                        |
| Traffic Generator | Seagull                                         |
| Protocol          | Diameter                                        |
| Environment       | R&D / Performance Testing                       |
| Affected Servers  | 192.168.149.109, 192.168.149.7, 192.168.149.201 |

---

## Problem Statement

During high-throughput Diameter performance testing, Seagull consistently failed while transmitting traffic.

Observed error:

```text
send failed [-1]
Resource temporarily unavailable
Flow control not implemented
```

The failures resulted in:

* Packet transmission failures
* Incomplete Diameter message exchanges
* Inability to reach the target TPS (Transactions Per Second)
* Performance testing interruptions

---

## Requirements

* Identify the cause of the transmission failures.
* Verify operating system resource limits.
* Tune the Linux networking stack for high-throughput workloads.
* Validate stable Diameter traffic generation.
* Restore performance testing capability.

---

## Investigation

### Step 1 – Verify System Health

The investigation began by validating the operating system.

Verified:

* CPU utilization
* Memory utilization
* Network interface statistics
* Disk I/O
* System load

Commands used:

```bash
top
vmstat
iostat
sar -n DEV
```

**Result**

* CPU healthy
* Memory healthy
* Network interfaces healthy
* No hardware bottlenecks observed

The issue did not appear to be resource exhaustion.

---

### Step 2 – Analyse Application Errors

Reviewed the Seagull logs.

Repeated errors were observed:

```text
send failed [-1]
Resource temporarily unavailable
Flow control not implemented
```

The error indicated that the application could not allocate sufficient networking resources to continue transmitting packets.

---

### Step 3 – Verify Kernel Networking Parameters

Reviewed the current kernel networking configuration.

```bash
sysctl -a
```

Checked:

```bash
sysctl net.core.rmem_max
sysctl net.core.wmem_max
sysctl net.core.somaxconn
sysctl net.ipv4.ip_local_port_range
```

Several parameters were still configured with default values.

The default socket buffer sizes and connection limits were insufficient for the required traffic volume.

---

### Step 4 – Verify File Descriptor Limits

Checked process file descriptor limits.

```bash
ulimit -n
```

Observed:

```text
1024
```

The default limit restricted the number of simultaneous sockets the traffic generator could create during high-load testing.

---

## Root Cause

The Linux servers were configured with the default kernel networking parameters and file descriptor limits.

Under high-throughput Diameter traffic generation:

* Socket receive buffers became exhausted.
* Socket transmit buffers reached their limits.
* TCP backlog queues filled rapidly.
* Available file descriptors became insufficient for the number of concurrent connections.

These operating system limits prevented Seagull from generating the required traffic, resulting in repeated **"Resource temporarily unavailable"** 
errors.

---

## Resolution

Updated the Linux kernel networking parameters.

Modified:

```text
/etc/sysctl.conf
```

Configured:

```ini
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.rmem_default = 8388608
net.core.wmem_default = 8388608
net.core.somaxconn = 65535
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_fin_timeout = 15
fs.file-max = 2097152
```

Applied the configuration.

```bash
sudo sysctl -p
```

Updated the user file descriptor limits.

Modified:

```text
/etc/security/limits.conf
```

Configured:

```text
* soft nofile 65535
* hard nofile 65535
```

Verified:

```bash
ulimit -n
```

Expected output:

```text
65535
```

---

## Validation

Performed another round of Diameter performance testing after applying the kernel tuning.

Verified:

* No socket allocation failures.
* No "Resource temporarily unavailable" errors.
* Stable Diameter traffic generation.
* Successful high-throughput load testing.
* Target TPS achieved without packet transmission failures.

---

## Outcome

* Successfully optimized Linux networking for high-volume traffic generation.
* Increased socket buffer capacity.
* Increased maximum file descriptor limits.
* Eliminated transmission failures.
* Restored successful Seagull Diameter performance testing.
* Improved operating system readiness for stress and performance testing.

---

## Root Cause Analysis (RCA)

| Component             | Status                                                                                                           |
| --------------------- | ---------------------------------------------------------------------------------------------------------------- |
| CPU                   | Healthy                                                                                                          |
| Memory                | Healthy                                                                                                          |
| Network Interface     | Healthy                                                                                                          |
| Seagull Application   | Functioning Normally                                                                                             |
| Socket Buffers        | Insufficient Default Values                                                                                      |
| File Descriptor Limit | Too Low                                                                                                          |
| TCP Networking        | Default Configuration                                                                                            |
| **Root Cause**        | Default Linux kernel networking and resource limits insufficient for high-throughput Diameter traffic generation |

---

## Technologies Used

* Red Hat Enterprise Linux
* Linux Kernel
* TCP/IP Stack
* Seagull
* Diameter Protocol
* Sysctl
* Linux Networking
* Performance Tuning
* File Descriptor Management
* Production Support

---

## Commands Used During Troubleshooting

### Check System Health

```bash
top
vmstat
iostat
sar -n DEV
```

### Verify Kernel Parameters

```bash
sysctl -a
sysctl net.core.rmem_max
sysctl net.core.wmem_max
sysctl net.core.somaxconn
sysctl net.ipv4.ip_local_port_range
```

### Apply Kernel Configuration

```bash
sudo sysctl -p
```

### Verify File Descriptor Limits

```bash
ulimit -n
cat /proc/sys/fs/file-max
```

### Apply New Limits

```text
/etc/security/limits.conf

* soft nofile 65535
* hard nofile 65535
```

---

## Key Learning

High-throughput applications often reach operating system limits before they exhaust CPU or memory resources. Default Linux kernel parameters 
are designed for general-purpose workloads and may not be suitable for telecom traffic generators or performance testing tools. By analysing socket
behaviour, kernel networking parameters, and file descriptor limits, it was possible to identify the operating system as the bottleneck rather than
the application itself. Proper tuning of the Linux networking stack significantly improved throughput and enabled reliable Diameter traffic 
generation under heavy load.

