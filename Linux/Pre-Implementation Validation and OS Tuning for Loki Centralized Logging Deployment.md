**Pre-Implementation Validation and OS Tuning for Loki Centralized Logging Deployment**

## Overview

As part of the centralized logging rollout for the SMSG application, infrastructure validation and operating system tuning were performed on the 
dedicated Loki server before deploying Loki and Vector in the production environment.

The objective was to ensure that the server and network infrastructure could sustain continuous log ingestion while meeting the recommended 
operating system limits for a production-grade Loki deployment.

---

## Environment

| Component               | Details       |
| ----------------------- | ------------- |
| Logging Platform        | Grafana Loki  |
| Log Collector           | Vector        |
| Loki Server             | 10.230.200.56 |
| SMSG Application Server | 10.230.200.45 |
| Operating System        | RHEL Linux    |
| Storage Allocated       | 300 GB        |
| Planned Log Retention   | 15 Days       |

---

## Requirements

The application team requested validation of the following before proceeding with production deployment:

* Disk I/O performance on the Loki server.
* Network latency and bandwidth between the SMSG Application Server and Loki Server.
* Operating system tuning for production workloads.
* Verification of storage capacity for projected log growth.

---

## Investigation

### Disk Performance Validation

Verified the storage mounted for Loki log data.

```bash
df -h /loggers
```

Performed sequential disk write testing.

```bash
dd if=/dev/zero of=/loggers/testfile bs=1G count=1 oflag=direct
```

**Result**

* Write throughput approximately **845 MB/s**
* Low write latency observed
* Storage performance suitable for continuous log ingestion.

---

### Network Validation

Verified network latency.

```bash
ping 10.230.200.56
```

Observed:

* Average latency below **0.5 ms**
* Zero packet loss

Validated network throughput using iperf3.

```bash
iperf3 -c 10.230.200.56
```

**Result**

* Sustained throughput approximately **10–12 Gbps**
* Stable network performance throughout testing

---

### Storage Planning

Validated available storage allocated for Loki.

```bash
df -h /loggers
```

Observed:

* Allocated Storage: **300 GB**
* Daily estimated log generation: **15–20 GB**
* Estimated retention: **Approximately 15 days**

---

### Operating System Validation

Verified current kernel parameters.

```bash
sysctl vm.max_map_count
```

Current value:

```text
65530
```

Verified open file limit.

```bash
ulimit -n
```

Current value:

```text
1024
```

The existing values were below the recommended limits for Loki production deployments.

---

## Root Cause

The Loki server was provisioned with the default Linux kernel parameters.

Default values for:

* `vm.max_map_count`
* Open file descriptors (`nofile`)

were insufficient for large-scale production log ingestion workloads.

---

## Resolution

Updated the kernel parameter.

```bash
sysctl -w vm.max_map_count=262144
```

Made the change persistent.

```bash
echo "vm.max_map_count = 262144" >> /etc/sysctl.conf

sysctl -p
```

Configured system-wide open file limits.

```text
* soft nofile 1048576
* hard nofile 1048576
root soft nofile 1048576
root hard nofile 1048576
```

Applied the new limits.

Verified the configuration.

```bash
sysctl vm.max_map_count

ulimit -n
```

Confirmed:

```text
vm.max_map_count = 262144

open files = 1048576
```

---

## Validation

Successfully validated:

* Disk write throughput approximately **845 MB/s**
* Network latency below **0.5 ms**
* Sustained network bandwidth approximately **10–12 Gbps**
* 300 GB storage available for Loki log retention
* `vm.max_map_count` increased to **262144**
* Open file limit increased to **1048576**
* Vector installed successfully and ready for log forwarding
* Infrastructure prepared for Loki production deployment

---

## Outcome

* Completed all requested pre-installation infrastructure validation.
* Confirmed that the Loki server storage and network met the required performance benchmarks.
* Applied recommended Linux kernel tuning for production log ingestion workloads.
* Increased operating system limits to support high-volume logging.
* Prepared the environment for successful Loki and Vector deployment.

---

## Technologies Used

* Red Hat Enterprise Linux
* Grafana Loki
* Vector
* Grafana
* Linux Kernel Tuning
* `sysctl`
* `ulimit`
* `iperf3`
* `dd`
* Linux Storage Administration
* Linux Performance Tuning
* Network Performance Testing

---

## Key Learning

Before deploying a centralized logging platform such as Grafana Loki, validating storage performance, network throughput, and operating system 
limits is critical to ensuring reliable log ingestion. Proactively tuning kernel parameters like `vm.max_map_count` and increasing open file limits 
helps prevent resource bottlenecks under heavy logging workloads, while disk and network benchmarking provides confidence that the infrastructure 
can sustain continuous production traffic.
