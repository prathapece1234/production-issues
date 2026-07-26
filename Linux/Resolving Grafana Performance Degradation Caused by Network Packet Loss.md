**Production Incident: Resolving Grafana Performance Degradation Caused by Network Packet Loss**

## Overview

The Mundo customer reported that the Grafana dashboard was loading very slowly and frequently refreshing. Initial investigation focused on the 
Grafana application and PostgreSQL database, as these components commonly contribute to dashboard performance issues.

Although Grafana logs showed repeated authentication failures caused by expired user session tokens, the server itself remained healthy with 
sufficient CPU, memory, and database resources. Further investigation extended to the network layer, where significant packet loss was identified
between the client network and the Grafana server.

The issue was traced to recent network changes performed within the Mundo environment. After the network configuration was rolled back, packet loss 
disappeared, authentication retries stopped, and Grafana performance returned to normal.

---

## Environment

| Component        | Details                  |
| ---------------- | ------------------------ |
| Operating System | Red Hat Enterprise Linux |
| Application      | Grafana                  |
| Database         | PostgreSQL (localhost)   |
| Monitoring       | OpsRamp                  |
| Environment      | Production               |
| Customer         | Mundo                    |

---

## Problem Statement

The customer reported:

* Grafana loading very slowly.
* Automatic page refreshes.
* Dashboard access delays.
* Intermittent failures while accessing the Grafana UI.

Grafana URL:

```text
http://172.17.0.65:3000
```

---

## Requirements

* Verify Grafana server health.
* Validate PostgreSQL connectivity.
* Identify the cause of dashboard slowness.
* Determine whether the issue was related to the application, database, or network.
* Restore normal dashboard performance.

---

## Investigation

### Step 1 – Verify Server Health

The investigation began with the Grafana server.

Verified:

* CPU utilization
* Memory utilization
* Disk usage
* Load average
* PostgreSQL status

Commands used:

```bash
top
free -h
df -h
systemctl status grafana-server
systemctl status postgresql
```

**Result**

* CPU utilization normal.
* Memory utilization normal.
* Disk utilization healthy.
* PostgreSQL running normally.
* No resource bottlenecks observed.

The server infrastructure was ruled out.

---

### Step 2 – Review Grafana Logs

Reviewed Grafana logs.

```bash
journalctl -u grafana-server
```

Observed repeated authentication failures.

Example:

```text
Failed to authenticate request
invalid session token: user token expired

Unauthorized

status=401
```

Multiple authentication retries were occurring from the same client.

Although these errors explained repeated login attempts, they did not explain the overall application slowness.

---

### Step 3 – Verify Database Performance

Since Grafana uses PostgreSQL locally, database connectivity was verified.

Validated:

* PostgreSQL availability
* Database response time
* Local connectivity

No database latency was observed.

The database was eliminated as the source of the issue.

---

### Step 4 – Verify Network Connectivity

Attention shifted toward network connectivity.

Performed connectivity tests.

```bash
ping 172.17.0.65
```

Observed:

```text
75% packet loss
```

Round-trip latency also increased significantly.

This immediately explained why browser requests and WebSocket sessions were repeatedly disconnecting.

---

### Step 5 – Correlate with Recent Changes

Further investigation revealed that the issue started immediately after recent network activities performed within the Mundo environment.

Additional verification showed that even the OpsRamp Gateway experienced packet loss while communicating with the same network devices.

This confirmed that the issue extended beyond Grafana itself.

---

## Root Cause

The Grafana server and PostgreSQL database were functioning normally.

The primary cause of the performance issue was **network packet loss introduced after recent network configuration changes in the Mundo 
environment**.

Because of the unstable network connection:

* Browser requests experienced delays.
* WebSocket connections repeatedly disconnected.
* Grafana generated repeated authentication failures due to expired session tokens.
* Users experienced slow dashboard loading and automatic page refreshes.

The authentication errors were therefore a secondary symptom rather than the root cause.

---

## Resolution

Performed temporary configuration adjustments to reduce automatic page refresh behaviour while the investigation continued.

The network team rolled back the recent network changes performed within the Mundo environment.

After rollback:

* Packet loss disappeared.
* Network latency normalized.
* Authentication retries stopped.
* Grafana dashboards loaded normally.

---

## Validation

Verified after rollback:

```bash
ping 172.17.0.65
```

Observed:

* No packet loss.
* Stable network latency.
* Grafana dashboard loaded normally.
* Authentication errors significantly reduced.
* OpsRamp Gateway communication restored.

---

## Outcome

* Successfully ruled out Grafana and PostgreSQL as the source of the issue.
* Identified network packet loss as the actual root cause.
* Restored stable Grafana performance.
* Eliminated repeated dashboard refreshes.
* Improved monitoring communication between the OpsRamp Gateway and network devices.

---

## Root Cause Analysis (RCA)

| Component           | Status                                                                               |
| ------------------- | ------------------------------------------------------------------------------------ |
| Linux Server        | Healthy                                                                              |
| CPU                 | Healthy                                                                              |
| Memory              | Healthy                                                                              |
| PostgreSQL          | Healthy                                                                              |
| Grafana Service     | Running Normally                                                                     |
| Authentication Logs | Secondary symptom                                                                    |
| Network             | Packet loss observed                                                                 |
| **Root Cause**      | Network configuration changes causing packet loss and unstable Grafana communication |

---

## Technologies Used

* Red Hat Enterprise Linux
* Grafana
* PostgreSQL
* OpsRamp
* TCP/IP Networking
* Linux System Administration
* Network Troubleshooting
* Production Incident Management

---

## Commands Used During Troubleshooting

### Verify Server Health

```bash
top
free -h
df -h
uptime
```

### Check Grafana Service

```bash
systemctl status grafana-server
journalctl -u grafana-server
```

### Verify PostgreSQL

```bash
systemctl status postgresql
```

### Test Network Connectivity

```bash
ping 172.17.0.65
```

---

## Key Learning

When troubleshooting web applications, authentication errors are not always the primary cause of poor performance. In this incident, the repeated 
**"user token expired"** messages initially appeared to indicate an application issue. However, by systematically validating the server, database, 
and network, it became clear that **network packet loss** was disrupting client connections and causing repeated authentication retries. Correlating 
application logs with network behaviour helped identify the true root cause and prevented unnecessary changes to the Grafana or PostgreSQL 
configuration.

