# Production Incident – XFS Filesystem Metadata Corruption Recovery

## Incident Summary

A production application experienced an unexpected filesystem failure caused by **XFS metadata corruption**. The affected mount point 
became inaccessible, resulting in application downtime.

The issue was diagnosed using kernel logs and XFS utilities. After stopping the application and unmounting the affected filesystem, 
`xfs_repair` successfully repaired the metadata corruption. The filesystem was remounted, and the application resumed normal operation.

A similar issue later occurred in the staging environment. However, due to severe filesystem corruption, `xfs_repair` was unable to 
recover the filesystem. Since no critical data existed on the staging server, the filesystem was recreated and mounted again.

---

## Environment

| Component | Details |
|-----------|---------|
| Operating System | Red Hat Enterprise Linux |
| Filesystem | XFS |
| Storage | LVM Logical Volume |
| Application | Production Application |

---

## Reported Issue

- Application became inaccessible.
- Mounted filesystem could not be accessed.
- Directory listing showed Input/Output errors.
- Multiple application directories became unavailable.

Example:

```bash
ls: cannot access 'app1': Input/output error
ls: cannot access 'app2': Input/output error
```
<img width="909" height="666" alt="image" src="https://github.com/user-attachments/assets/4b44b038-5c59-492e-abb4-4ad05deec492" />

---

## Symptoms

- Application outage.
- Filesystem returned Input/Output errors.
- XFS kernel reported metadata corruption.
- Mount point became unstable.

---

## Kernel Logs

The following messages were observed in the system logs:

```text
Corruption of in-memory data detected.

XFS: Shutting down filesystem.

Please unmount the filesystem and rectify the problem(s).

Metadata CRC error detected.

Metadata has LSN ahead of current LSN.

Unmount and run xfs_repair.
```

These messages confirmed XFS metadata corruption.

---

## Investigation

Performed the following verification steps:

- Checked application status.
- Verified mounted filesystems.
- Reviewed kernel logs.
- Identified XFS metadata corruption.
- Confirmed filesystem shutdown initiated by the XFS kernel.

---

## Production Recovery Procedure

### Step 1

Stopped the production application to prevent further writes.

---

### Step 2

Unmounted the affected filesystem.

```bash
umount /app1
```

---

### Step 3

Executed XFS repair.

```bash
xfs_repair /dev/mapper/rhel-app1
```

The utility repaired the corrupted filesystem metadata successfully.

---

### Step 4

Mounted the filesystem again.

```bash
mount /app1
```

---

### Step 5

Verified:

- Filesystem accessibility
- Application files
- Mount status
- Application startup

The production application started successfully.

---

## Result

Production filesystem recovered successfully.

Application restored without requiring backup restoration.

---

# Staging Environment

A similar metadata corruption occurred on the staging server.

Performed the same recovery procedure.

```bash
xfs_repair -n /dev/mapper/rhel-app1
```

Output:

```text
bad primary superblock

attempting to find secondary superblock

Sorry, could not find valid secondary superblock
```

The filesystem could not be repaired because the metadata corruption was beyond recovery.

---

## Staging Recovery

Since the staging environment did not contain critical data:

- Removed the corrupted filesystem.
- Recreated the XFS filesystem.
- Mounted the new filesystem.
- Restored the mount configuration.
- Redeployed the application data.

Example:

```bash
mkfs.xfs /dev/vdb
```

Updated `/etc/fstab` and mounted the filesystem.

```bash
mount -a
```

Filesystem was restored successfully.

---

## Root Cause

The incident was caused by XFS filesystem metadata corruption.

The kernel detected corrupted metadata structures and automatically shut down the filesystem to prevent additional damage.

Production corruption was repairable using `xfs_repair`.

The staging filesystem had severe metadata damage and could not be recovered.

---

## Resolution

### Production

- Stopped application.
- Unmounted filesystem.
- Executed `xfs_repair`.
- Mounted filesystem.
- Verified application functionality.

### Staging

- Attempted `xfs_repair`.
- Recovery failed due to unrecoverable metadata corruption.
- Recreated the filesystem.
- Mounted the new filesystem.
- Restored application environment.

<img width="1085" height="175" alt="image" src="https://github.com/user-attachments/assets/d2f3b8eb-e605-475d-9958-0913c01c84b7" />
<img width="1083" height="100" alt="image" src="https://github.com/user-attachments/assets/95da0113-81dd-475e-bdf4-4f546d062de4" />


---

## Validation

Verified:

- Filesystem mounted successfully.
- No Input/Output errors.
- Application directories accessible.
- Services started successfully.
- Application functionality restored.

---

## Result

| Production | Staging |
|------------|----------|
| XFS metadata repaired | Recovery failed |
| Filesystem restored | Filesystem recreated |
| Application resumed | Mount recreated |
| No backup restoration required | Fresh filesystem deployed |

---

## Lessons Learned

- Always stop applications before performing filesystem repairs.
- Never run `xfs_repair` on a mounted filesystem.
- Review kernel logs immediately after filesystem errors.
- Regular backups are essential for production recovery.
- Severe metadata corruption may require filesystem recreation if repair is unsuccessful.
- Validate filesystem health after recovery before restarting production services.

---

## Technologies Used

- Red Hat Enterprise Linux
- XFS Filesystem
- Logical Volume Manager (LVM)
- xfs_repair
- Kernel Log Analysis
- Filesystem Recovery
- Production Incident Management
- Linux Storage Administration
