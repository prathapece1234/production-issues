# PostgreSQL Replication WAL and LVM Thin Pool Space Resolution

## Incident Summary
A PostgreSQL standby replication server failed to continue streaming replication after falling behind the primary server during downtime.
At the same time, LVM thin pool utilization showed critically high `Data%` usage despite low filesystem usage reported by `df -h`.


## Environment
- Database: PostgreSQL
- Replication Type: Streaming Replication
- Storage: LVM Thin Pool
- OS: Linux


## Symptoms Observed
- PostgreSQL replication stopped
- Standby unable to receive WAL segments
- Replication lag increased significantly
- WAL segment missing from primary server
- LVM thin pool showing high `Data%`
- Filesystem usage appeared much lower in `df -h`


## Investigation

### PostgreSQL Replication Validation
Observed replication failure:
requested WAL segment has already been removed


### Root Cause

During downtime, the primary PostgreSQL server removed WAL segment: 000000010000009C00000052

before the standby server could receive and apply it.

As a result:

* Standby replication fell too far behind
* Streaming replication could not resume automatically
* WAL archive no longer available on primary

## Storage Investigation

### LVM Thin Pool Analysis

Checked:
lvs
df -h

### Findings

* `lvs` showed very high `Data%`
* `df -h` showed significantly lower filesystem usage

Example:

* Thin pool Data%: ~90%
* Actual filesystem usage: ~30%


## Root Cause of Thin Pool Usage

Deleted filesystem blocks were not reclaimed automatically by the thin pool.

Although files were deleted:

* Filesystem released them
* LVM thin pool still considered blocks allocated
* Thin pool utilization remained high

---

## Resolution Process

### Step 1: Reclaim Unused Blocks

Executed TRIM operation on affected filesystem:

fstrim -v /var

For all mounted filesystems:

fstrim -av


### Result

* Unused blocks reclaimed successfully
* Thin pool Data% reduced
* Storage allocation normalized

## Step 2: Automate TRIM Operations

Validated TRIM timer service:

systemctl status fstrim.timer

Configured periodic TRIM execution to prevent future thin pool over-allocation issues.

---

## Final Outcome

* LVM thin pool utilization reduced
* Storage allocation corrected
* Unused blocks reclaimed successfully
* PostgreSQL replication issue analyzed and isolated
* Storage environment stabilized

## Preventive Measures

* Enable periodic filesystem TRIM operations
* Monitor PostgreSQL replication lag proactively
* Configure WAL retention appropriately
* Monitor thin pool Data% regularly
* Validate standby replication health continuously
* Enable `fstrim.timer` permanently


## Key Learning

### Major Insights:

* PostgreSQL standby servers can fail permanently if WAL retention is insufficient
* Thin pool Data% may not match actual filesystem usage
* Deleted blocks are not always reclaimed automatically
* TRIM operations are critical for thin-provisioned storage environments
* Monitoring replication lag prevents WAL loss scenarios


## Severity

**Production Database Replication and Storage Issue**

## Skills Demonstrated

* PostgreSQL replication troubleshooting
* WAL segment analysis
* Linux storage troubleshooting
* LVM thin pool management
* Filesystem TRIM operations
* Database infrastructure support
* Production troubleshooting
* Root cause analysis

## Business Impact

* Prevented storage exhaustion
* Improved storage utilization accuracy
* Stabilized database infrastructure
* Enhanced replication monitoring awareness

