# Production SSH Login Failure – PTY Limit Exhaustion

## Incident Summary

A production Linux server was running normally, and existing SSH/PuTTY sessions were working without any issues. However, new SSH login attempts for 
users were failing.

The SSH service was healthy and port `22` was listening. Network connectivity to the server was also confirmed.

The issue was eventually identified as **PTY (Pseudo-Terminal) exhaustion**. The server had reached the configured maximum PTY limit of `4096`, 
preventing new interactive SSH sessions from obtaining a PTY.

---

## Symptoms

New SSH/PuTTY connections were unable to establish an interactive session, while existing sessions continued to work normally.

### What was working

* Server reachable through the network
* Gateway could ping the server
* SSH port `22` was listening
* `sshd` service was running
* Existing SSH sessions were working
* User password was valid
* User account was not locked
* Password had not expired

### What was failing

* New SSH/PuTTY sessions
* Interactive terminal creation

---

## Initial Troubleshooting

### 1. Verify network connectivity

From the gateway:

```bash
ping <server-ip>
```

Network connectivity was successful.

---

### 2. Check SSH port

```bash
nc -zv <server-ip> 22
```

or:

```bash
telnet <server-ip> 22
```

Port `22` was reachable.

---

### 3. Check SSH service

```bash
systemctl status sshd
```

The SSH daemon was running normally.

Verify listening socket:

```bash
ss -lntp | grep ':22'
```

Expected:

```text
LISTEN 0 128 0.0.0.0:22 0.0.0.0:*
```

Therefore, this was not a basic SSH service or port-listening issue.

---

## 4. Check User Account

Verify the account:

```bash
passwd -S <username>
```

Check password aging:

```bash
chage -l <username>
```

The user was:

* Not password locked
* Not account locked
* Password was not expired
* Account was valid

Therefore, authentication policy was not the root cause.

---

# Root Cause Investigation – PTY Exhaustion

A PTY is a **Pseudo-Terminal** allocated for interactive sessions such as SSH and PuTTY.

Check the current PTY usage:

```bash
cat /proc/sys/kernel/pty/nr
```

Check the configured maximum:

```bash
cat /proc/sys/kernel/pty/max
```

Observed:

```text
kernel.pty.nr  = 4095
kernel.pty.max = 4096
```

This showed that the server was effectively at its PTY allocation limit.

Existing sessions continued to function because their PTYs had already been allocated.

New SSH/PuTTY sessions could not obtain another PTY.

---

# Why `pts/4095` Was Significant

The active sessions showed high PTY numbers, for example:

```text
prathap pts/4090
prathap pts/4091
prathap pts/4092
prathap pts/4093
prathap pts/4094
prathap pts/4095
```

The server had reached the configured PTY allocation limit.

The important distinction is:

> `pts/4095` is an indication of the high PTY allocation level; it is not simply a "user session number."

PTYs are represented under:

```bash
/dev/pts/
```

Check:

```bash
ls /dev/pts/
```

---

# Check PTY Consumers

Before increasing the limit, identify which processes/sessions are consuming PTYs.

```bash
who
```

```bash
w
```

```bash
loginctl list-sessions
```

Check processes associated with terminals:

```bash
ps -ef | grep pts
```

You can also inspect:

```bash
ls -l /proc/*/fd/* 2>/dev/null | grep '/dev/pts/'
```

The goal is to determine whether the PTYs are associated with:

* Legitimate active users
* Long-running SSH sessions
* Stale sessions
* Automation
* Terminal multiplexers
* Applications that failed to release PTYs

---

# Temporary Mitigation

Because this was a production server and new user access was required immediately, the PTY maximum was temporarily increased.

Current value:

```bash
cat /proc/sys/kernel/pty/max
```

Temporary increase:

```bash
sysctl -w kernel.pty.max=8096
```

Verify:

```bash
cat /proc/sys/kernel/pty/max
```

Expected:

```text
8096
```

After increasing the limit, a new SSH/PuTTY session could be established successfully.

### Important

This change is **temporary**.

It modifies the running kernel parameter and is not intended as the permanent fix.

---

# Why Existing Sessions Continued Working

The problem affected **new PTY allocation**, not existing terminal sessions.

Conceptually:

```text
Existing SSH sessions
        |
        +---- PTY already allocated
        |
        +---- Continue working
```

But:

```text
New SSH connection
        |
        v
sshd
        |
        v
Request new PTY
        |
        v
PTY limit reached
        |
        X
Cannot create new interactive session
```

Therefore, it was possible for:

```text
SSH service = RUNNING
Port 22      = LISTENING
Existing SSH = WORKING
```

while:

```text
New SSH login = FAILING
```

---

# Permanent Fix / Follow-up

The temporary increase should not be considered the final resolution.

Investigate why the server reached the PTY limit.

### Check current sessions

```bash
who
```

```bash
w
```

```bash
loginctl list-sessions
```

### Check SSH sessions

```bash
ss -tnp | grep ':22'
```

### Check processes

```bash
ps -ef
```

### Check system logs

```bash
journalctl -u sshd
```

### Check PTY configuration

```bash
sysctl kernel.pty.max
sysctl kernel.pty.nr
```

---

# Important Observation

The server had been running for more than three years.

However:

> **Long uptime alone does not consume PTYs.**

PTYs are allocated when terminal sessions/processes require them and are normally released when those sessions/processes exit.

Therefore, reaching the PTY limit after a long uptime should trigger an investigation into:

* Large number of concurrent sessions
* Stale sessions
* Applications creating PTYs
* Automation jobs
* Long-running terminal sessions
* Incorrect session cleanup
* Process/PTY leaks

---

# Temporary vs Permanent Configuration

Temporary:

```bash
sysctl -w kernel.pty.max=8096
```

Verify:

```bash
sysctl kernel.pty.max
```

For a permanent configuration, add the setting to an appropriate sysctl configuration file, for example:

```text
/etc/sysctl.d/99-pty.conf
```

with:

```text
kernel.pty.max = 8096
```

Then apply:

```bash
sysctl --system
```

However, **do not make the permanent change blindly**. First determine why PTY usage reached the existing limit and choose an appropriate capacity 
based on the server's workload.

---

# RCA

### Problem

New SSH/PuTTY users could not establish interactive sessions.

### Impact

New interactive SSH sessions were blocked, while existing sessions continued to operate normally.

### Root Cause

The server reached the configured maximum PTY allocation:

```text
kernel.pty.nr ≈ kernel.pty.max
```

with the maximum configured at:

```text
4096
```

### Immediate Resolution

Temporarily increased the PTY maximum:

```bash
sysctl -w kernel.pty.max=8096
```

### Verification

```bash
cat /proc/sys/kernel/pty/nr
cat /proc/sys/kernel/pty/max
```

A new PuTTY/SSH connection was successfully established.

### Permanent Action

Investigate the source of excessive PTY consumption and determine whether the server requires:

* Session cleanup
* Application/process correction
* Stale session cleanup
* Monitoring/alerting
* A permanently higher PTY limit

---

# Troubleshooting Flow

```text
New SSH login fails
        |
        v
Can server be pinged?
        |
       YES
        |
        v
Is TCP/22 reachable?
        |
       YES
        |
        v
Is sshd running?
        |
       YES
        |
        v
Existing sessions working?
        |
       YES
        |
        v
Check user account
passwd -S
chage -l
faillock
        |
        v
Account OK?
        |
       YES
        |
        v
Check PTY usage
cat /proc/sys/kernel/pty/nr
cat /proc/sys/kernel/pty/max
        |
        v
PTY limit reached?
        |
       YES
        |
        v
Identify PTY consumers
who
w
loginctl
ps
        |
        v
Temporary mitigation
sysctl -w kernel.pty.max=8096
        |
        v
Test new SSH session
        |
        v
Investigate permanent root cause
```
