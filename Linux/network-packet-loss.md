# Network Packet Loss Troubleshooting and Resolution

## Incident Summary
The Linux server experienced intermittent network packet loss and unstable SSH connectivity. Commands entered through SSH responded slowly or intermittently hung, even though CPU, memory, and disk utilization remained healthy.

---

## Environment
- OS: RHEL Linux
- Interface: ens34
- IP Address: 192.168.144.14/22

---

## Symptoms Observed
- SSH terminal response delay
- Intermittent command execution lag
- Random packet loss to gateway
- Ping instability
- Network connectivity fluctuating between reachable and unreachable

Example:
ping 192.168.144.1

Observed:

* 50%–100% packet loss intermittently
* Random connectivity instability
---

## Initial Investigation

### System Resource Validation

Checked:

top
free -m
df -h
uptime


### Result

* CPU utilization normal
* Memory usage normal
* Disk utilization healthy
* Load average low

This confirmed the issue was network-related rather than server resource-related.

---

## Network Diagnostics Performed

### 1. Interface Verification

Checked:
ifconfig -a
ip link show
ip route show

### Observed

* ens34 active with valid IP configuration
* No interface down state
* Network route configuration normal

---

### 2. Gateway Connectivity Test

Executed:
ping 192.168.144.1


### Observed

* Intermittent packet loss
* Occasional 100% packet drop
* Random successful replies

### 3. ARP Validation

Executed:
arping -I ens34 192.168.144.1

### Result

* ARP replies received consistently
* Layer-2 communication healthy

---

## Neighbor Table Analysis

### Initial State

Observed stale neighbor entry:

ip neigh

Output:

192.168.144.5 dev ens34 lladdr 00:0c:29:f5:12:55 STALE
192.168.144.1 dev ens34 lladdr 00:17:5a:8d:a7:c3 REACHABLE

---

## Root Cause

### Primary Issue:

Neighbor table instability and stale ARP state caused intermittent packet loss and delayed SSH terminal responsiveness.

---

## Resolution Process

### Step 1: Interface Recovery

Restarted network interface:
ip link set ens34 down
ip link set ens34 up

### Step 2: Neighbor State Validation

Verified neighbor table:

ip neigh show


Observed stabilized state:

192.168.144.5 dev ens34 lladdr 00:0c:29:f5:12:55 REACHABLE
192.168.144.1 dev ens34 lladdr 00:17:5a:8d:a7:c3 REACHABLE

---

## Final Outcome

* Packet loss reduced significantly
* SSH responsiveness restored
* Terminal command execution normalized
* Neighbor entries stabilized
* Network connectivity improved successfully

---

## Preventive Measures

* Monitor packet loss continuously
* Validate neighbor table during SSH latency issues
* Include ARP diagnostics in network troubleshooting
* Monitor VMware vmxnet3 driver stability
* Perform periodic network health validation

---

## Key Learning

### Major Insights:

* SSH slowness can originate from intermittent network instability
* Stale neighbor table entries may impact communication reliability
* System resource health does not always indicate network stability
* Layer-2 validation helps isolate network issues effectively

---

## Severity

**Production Network Connectivity Issue**

---

## Skills Demonstrated

* Linux network troubleshooting
* Packet loss analysis
* ARP and neighbor table diagnostics
* SSH performance troubleshooting
* Interface recovery
* Production incident handling
* Root cause analysis

---

## Business Impact

* Restored stable administrative access
* Improved server responsiveness
* Reduced operational delays
* Restored reliable network communication

