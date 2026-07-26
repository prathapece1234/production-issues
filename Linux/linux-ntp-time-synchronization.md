**Production Incident: Improving Multi-Server Time Synchronization Using a Common NTP Source**

## Overview

A production application team reported time differences between three Linux servers. Initially, the servers showed noticeable differences in both 
**seconds and milliseconds**, causing application timestamp inconsistencies.

The first requirement was to synchronize the server clocks. After manually correcting the system time, the servers were aligned. However, the 
application team later observed that there was still a **500–700 ms difference** between the servers and requested synchronization at the 
millisecond level.

A detailed investigation was performed to verify the NTP configuration and synchronization source. All three servers were configured to use the 
same NTP server, significantly reducing the time difference to approximately **50–100 ms**, which is within normal expectations for NTP-based 
synchronization.

---

## Environment

| Component            | Details                         |
| -------------------- | ------------------------------- |
| Operating System     | Red Hat Enterprise Linux        |
| Time Synchronization | NTP / Chrony                    |
| Environment          | Production                      |
| Affected Servers     | Three Linux Application Servers |

---

## Problem Statement

The application team observed inconsistent timestamps across three production servers.

Initial observations included:

* Difference in seconds between servers.
* Difference in milliseconds.
* Application timestamp mismatch.

The requirement was to:

* Synchronize all three servers to IST.
* Ensure all servers used the same time source.
* Minimize millisecond differences between servers.

---

## Requirements

* Verify current system time.
* Synchronize all servers to IST.
* Configure a common NTP source.
* Reduce clock drift between servers.
* Validate synchronization.

---

## Investigation

### Step 1 – Verify Current Time

Verified the current system time on all three servers.

```bash
date
timedatectl
```

Observed that the servers were not fully synchronized and there was a noticeable difference in both seconds and milliseconds.

---

### Step 2 – Initial Time Synchronization

Performed manual synchronization to align the server clocks.

Verified:

```bash
date
```

The servers now displayed the same date and time.

However, the application team later observed a remaining **500–700 ms difference** during application testing.

---

### Step 3 – Verify NTP Configuration

Reviewed the NTP/Chrony configuration.

Checked:

```bash
chronyc sources
chronyc tracking
timedatectl status
```

Confirmed that the servers were not consistently synchronizing from the same reference source.

---

### Step 4 – Configure Common NTP Server

Configured all three servers to synchronize with the same NTP server.

Restarted the time synchronization service.

```bash
systemctl restart chronyd
```

Forced synchronization.

```bash
chronyc makestep
```

Verified synchronization.

```bash
chronyc tracking
chronyc sources -v
```

---

## Root Cause

Initially, the server clocks were manually synchronized, which corrected the visible time difference but did not prevent ongoing clock drift.

The remaining **500–700 ms difference** occurred because the servers were not consistently synchronized to a common NTP reference.

After configuring all three servers to use the same NTP source, clock drift was significantly reduced.

The remaining **50–100 ms difference** was due to normal NTP behaviour, including:

* Network latency
* CPU scheduling delays
* NTP polling intervals
* Minor clock drift between synchronization cycles

These variations are expected in distributed Linux systems and do not indicate a synchronization failure.

---

## Resolution

Configured all three servers to use the same NTP source.

Verified synchronization using:

```bash
chronyc tracking
chronyc sources
timedatectl status
```

Restarted the Chrony service.

```bash
systemctl restart chronyd
```

Forced immediate synchronization.

```bash
chronyc makestep
```

Validated that all servers were synchronizing from the same NTP reference.

---

## Validation

Performed validation after the configuration update.

Verified:

* All servers synchronized to the same NTP source.
* IST timezone configured correctly.
* Seconds synchronized across all servers.
* Millisecond variation reduced significantly.

Observed comparison:

| Before     | After     |
| ---------- | --------- |
| 500–700 ms | 50–100 ms |

Confirmed that the remaining offset was within expected operational limits for NTP synchronization.

---

## Outcome

* Successfully synchronized all three production servers.
* Configured a common NTP source.
* Reduced clock drift from approximately **500–700 ms** to **50–100 ms**.
* Improved timestamp consistency across applications.
* Explained expected NTP behaviour and acceptable synchronization tolerances to the application team.

---

## Root Cause Analysis (RCA)

| Component               | Status                                                                                         |
| ----------------------- | ---------------------------------------------------------------------------------------------- |
| Operating System        | Healthy                                                                                        |
| Time Zone               | IST Configured                                                                                 |
| NTP Service             | Healthy                                                                                        |
| Initial Synchronization | Manual                                                                                         |
| Final Synchronization   | Common NTP Source                                                                              |
| Remaining Offset        | Normal NTP variation (50–100 ms)                                                               |
| **Root Cause**          | Servers were not consistently synchronized to a common NTP source before configuration changes |

---

## Technologies Used

* Red Hat Enterprise Linux
* Chrony
* NTP
* Time Synchronization
* Linux System Administration
* Production Support
* Infrastructure Troubleshooting

---

## Commands Used During Troubleshooting

### Verify Time

```bash
date
timedatectl
```

### Verify NTP Status

```bash
chronyc tracking
chronyc sources -v
timedatectl status
```

### Restart Chrony

```bash
systemctl restart chronyd
```

### Force Immediate Synchronization

```bash
chronyc makestep
```

### Verify Synchronization

```bash
chronyc tracking
chronyc sources
```

---

## Key Learning

Perfect millisecond-level synchronization across multiple Linux servers is not guaranteed with standard NTP because each server experiences 
different network latency, CPU scheduling delays, and clock drift between synchronization intervals. The objective of NTP is to keep systems 
closely aligned to a common time reference rather than maintaining identical timestamps at every instant. In this incident, configuring all servers 
to use the same NTP source reduced the clock offset from approximately **500–700 ms** to **50–100 ms**, providing stable and reliable time 
synchronization suitable for production workloads.

