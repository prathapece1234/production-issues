# AWS EC2 Root Filesystem Expansion to Resolve Critical Disk Utilization

## Incident Summary

A production staging server hosted on AWS reported that the root filesystem had reached **100% utilization**, preventing normal system operations 
and posing a risk to application availability.

The server was using an XFS filesystem on an Amazon EBS root volume. Since the root volume size was relatively small (6.8 GB), the storage was 
expanded to **20 GB**, and the XFS filesystem was grown online without requiring a server rebuild.

---

## Initial Symptoms

* Root filesystem reached **100% utilization**.
* No free disk space available.
* Risk of application failures due to insufficient storage.
* Unable to create new files or logs.
* Monitoring generated critical disk space alerts.

---

## Investigation

### Initial Findings

Checked filesystem utilization.

```bash
df -kh
```

Observed:

```text
Filesystem      Size  Used Avail Use% Mounted on
/dev/root       6.8G  6.7G     0 100% /
```

Verified that the root volume was significantly undersized for the server workload.

Confirmed the filesystem type was **XFS**, allowing online filesystem expansion.

---

## Root Cause

### Primary Issue

The root EBS volume was provisioned with only **6.8 GB**, which was insufficient for the operating system, application files, and log growth.

### Technical Cause

* Small root EBS volume.
* Continuous operating system and application growth.
* Root filesystem reached full capacity.
* XFS filesystem required expansion after increasing the underlying EBS volume.

---

## Resolution Process

### Step 1: Increase EBS Volume

Expanded the AWS EBS root volume from:

* **6.8 GB**
* **20 GB**

using the AWS Management Console.

### Step 2: Verify Updated Block Device

Verified that the operating system detected the new disk size.

```bash
lsblk
```

### Step 3: Grow the Partition

Expanded the root partition.

```bash
growpart /dev/nvme0n1 1
```

### Step 4: Expand the XFS Filesystem

Extended the XFS filesystem online.

```bash
xfs_growfs /
```

### Step 5: Validation

Verified the updated filesystem capacity.

```bash
df -h
```

Confirmed that the root filesystem reflected the newly allocated storage and sufficient free space was available.

---

## Final Outcome

* Root filesystem successfully expanded.
* Server returned to a healthy state.
* No application downtime.
* Sufficient free space restored.
* Future disk space alerts eliminated.

---

## Preventive Measures

* Monitor root filesystem utilization proactively.
* Configure disk usage alerts before utilization exceeds 80%.
* Provision appropriate root volume sizes during server deployment.
* Review storage requirements periodically.
* Expand EBS volumes before critical thresholds are reached.

---

## Key Learning

### Major Insights

* XFS filesystems support online expansion without requiring unmounting.
* Amazon EBS volumes can be resized without rebuilding the server.
* Small default root volumes may become insufficient as applications and logs grow.
* Proactive storage monitoring prevents service interruptions caused by full filesystems.

---

## Severity

**Production Infrastructure – Critical Disk Space Issue**

---

## Skills Demonstrated

* AWS EC2 Administration
* Amazon EBS Volume Management
* Linux Storage Administration
* XFS Filesystem Management
* Capacity Planning
* Production Change Management
* Root Cause Analysis (RCA)
* Infrastructure Support

---

## Business Impact

* Prevented application downtime caused by disk exhaustion.
* Restored normal server operations.
* Increased storage capacity without rebuilding the server.
* Improved infrastructure reliability through proactive capacity management.
* Reduced the risk of future storage-related incidents.
