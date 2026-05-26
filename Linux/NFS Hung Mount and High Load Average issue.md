# NFS Hung Mount and High Load Average Resolution

## Incident Summary
The production Mundo DB server `munmspdb2` experienced a significantly high load average caused by a hung NFS mount on the 
path `/MUNRMAN_BKP`.

## Environment
- OS: RHEL/CentOS Linux
- NFS Server: `172.17.0.59`
- Mount Path: `/MUNRMAN_BKP`
- Production Server: `munmspdb2`


## Symptoms Observed
- High system load average
- `df`, `ls`, and `findmnt` commands hanging
- NFS filesystem inaccessible
- Blocked I/O operations
- System responsiveness degraded
- NFS mount operations hanging indefinitely

## Investigation

### Initial Validation

uptime
df -h
findmnt
ls

### Findings

* Commands accessing `/MUNRMAN_BKP` became unresponsive
* System load increased due to blocked I/O processes


## Network and NFS Validation

### Connectivity Check

Verified NFS server reachable:
ping 172.17.0.59
showmount -e 172.17.0.59

### Result

* Network connectivity healthy
* NFS exports visible
* NFS server reachable successfully

### Root Cause Identified

Although the server was reachable over the network, the NFS service became unresponsive to filesystem access requests, 
causing the client-side kernel NFS stack to hang.

This resulted in:

* Blocked filesystem calls
* Hanging mount operations
* Increased system load average
* Stale TCP session retention

---

## Resolution Process

### Step 1: Attempted Normal Unmount

Attempted regular unmount operation:

umount /MUNRMAN_BKP

### Observed

* Unmount operation hung
* Kernel blocked due to stale NFS operations

---

## Step 2: Lazy Unmount

Performed lazy unmount to detach the hung filesystem:

umount -f -l /MUNRMAN_BKP


### Result

* Filesystem detached successfully
* System commands restored
* Load average reduced partially


## Step 3: NFS Client Recovery

Restarted NFS client service:

systemctl restart nfs-client.target

### Observed

* Old TCP session still remained established
* Kernel retained stale NFS session
* Remount attempts still hanging

---

## Step 4: Final Resolution

Performed controlled server reboot to clear:

* Stale kernel NFS state
* Hung NFS client sessions
* Lingering TCP connections

### Post Reboot

* NFS mounts restored successfully
* `/MUNRMAN_BKP` mounted normally
* Load average normalized
* Filesystem operations restored

---

## Final Outcome

* Hung NFS mount resolved
* System load average normalized
* NFS connectivity restored
* Filesystem operations functioning correctly
* Production server stabilized

---

## Preventive Measures

* Monitor NFS responsiveness proactively
* Validate storage access latency regularly
* Avoid prolonged stale NFS sessions
* Monitor blocked I/O processes
* Escalate persistent NFS hangs early
* Validate backup mount stability periodically

---

## Key Learning

### Major Insights:

* NFS filesystem hangs can significantly increase Linux load average
* Server reachability does not guarantee NFS service responsiveness
* Hung NFS mounts can block standard Linux filesystem commands
* Lazy unmount helps detach blocked mounts temporarily
* Persistent kernel NFS hangs may require reboot for complete recovery

---

## Severity

**Production Storage and Performance Issue**

---

## Skills Demonstrated

* Linux NFS troubleshooting
* Load average analysis
* Filesystem recovery
* Kernel-level troubleshooting
* Storage connectivity diagnostics
* NFS client recovery
* Production incident management
* Root cause analysis

---

## Business Impact

* Restored production backup mount access
* Reduced system load and instability
* Recovered normal filesystem operations
* Improved production server reliability

