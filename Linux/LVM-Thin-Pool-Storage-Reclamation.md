# Linux Disk Space Alert Due to LVM Thin Pool Capacity Exhaustion

## Incident Summary

A production Red Hat Enterprise Linux server reported that the root filesystem was nearly full. However, filesystem analysis showed minimal disk 
usage, creating a mismatch between reported capacity and actual file consumption.

Further investigation revealed that the server was using **LVM Thin Provisioning**, where the thin pool had reached approximately **96% utilization**.
Although files had already been deleted, the storage blocks were not automatically reclaimed by the thin pool.

The issue was resolved by reclaiming unused blocks using `fstrim` and enabling automatic weekly TRIM operations.

---

## Initial Symptoms

* Root filesystem reported high disk utilization.
* Monitoring generated disk space alerts.
* `df -h` indicated the filesystem was almost full.
* `du` output showed significantly less disk usage.
* No large files identified.
* Deleting files did not reduce reported storage utilization.

---

## Investigation

### Initial Findings

Verified filesystem usage.

```bash
df -h
```

Filesystem utilization remained high.

Reviewed directory sizes.

```bash
du -sh /*
```

No unusually large directories were found.

Checked for deleted files still held open by running processes.

```bash
lsof +L1
```

No deleted open files were consuming storage.

Since the filesystem usage could not explain the reported disk utilization, storage configuration was investigated further.

---

## Root Cause

### Primary Issue

The server was configured with **LVM Thin Provisioning**.

Although files had been deleted from the filesystem, the underlying thin pool had not reclaimed the released blocks.

The LVM thin pool had reached approximately **96% utilization**, causing the operating system to report storage exhaustion despite relatively low filesystem usage.

### Technical Cause

* Thin-provisioned logical volumes.
* Deleted filesystem blocks not reclaimed automatically.
* Thin pool utilization continued increasing.
* Storage blocks remained allocated until a TRIM operation was performed.

---

## Resolution Process

### Step 1: Verify LVM Configuration

Reviewed logical volume configuration.

```bash
lvs
```

Confirmed the system was using LVM Thin Provisioning.

Reviewed thin pool allocation.

```bash
lvs -o +data_percent,metadata_percent
```

Observed the thin pool utilization was approximately **96%**.

### Step 2: Reclaim Unused Storage

Executed a manual TRIM operation.

```bash
fstrim -v /
```

Unused filesystem blocks were released back to the thin pool.

### Step 3: Validate Storage Utilization

Verified that thin pool utilization decreased after the TRIM operation.

Confirmed sufficient free capacity was available.

### Step 4: Prevent Future Occurrences

Enabled the system TRIM service to perform automatic weekly block reclamation.

```bash
systemctl enable fstrim.timer
systemctl start fstrim.timer
```

Verified the timer status.

```bash
systemctl status fstrim.timer
```

---

## Final Outcome

* Thin pool utilization reduced successfully.
* Disk space alerts cleared.
* Filesystem returned to normal operating capacity.
* Automatic weekly TRIM enabled.
* Prevented future storage reclamation issues.

---

## Preventive Measures

* Monitor LVM Thin Pool utilization separately from filesystem usage.
* Enable the `fstrim.timer` service on systems using thin provisioning.
* Include thin pool monitoring in infrastructure health checks.
* Investigate storage architecture when `df` and `du` values differ significantly.
* Configure monitoring alerts for thin pool utilization thresholds.

---

## Key Learning

### Major Insights

* High filesystem usage is not always caused by large files.
* On thin-provisioned LVM systems, deleted files do not immediately free storage at the thin pool level.
* `df`, `du`, and `lsof` alone may not identify the root cause of storage exhaustion.
* `fstrim` is required to return unused blocks to the storage pool on systems supporting discard/TRIM.
* Monitoring both filesystem utilization and thin pool usage is essential in enterprise Linux environments.

---

## Severity

**Production Infrastructure – Critical Storage Capacity Issue**

---

## Skills Demonstrated

* Red Hat Enterprise Linux Administration
* LVM Thin Provisioning
* Linux Storage Management
* Filesystem Analysis
* Capacity Planning
* TRIM / Discard Operations
* Root Cause Analysis (RCA)
* Performance Optimization
* Production Incident Management

---

## Business Impact

* Restored available storage without expanding disks or filesystems.
* Prevented application outages caused by thin pool exhaustion.
* Eliminated recurring disk space alerts.
* Improved storage efficiency through automatic block reclamation.
* Enhanced monitoring and operational practices for thin-provisioned Linux systems.
