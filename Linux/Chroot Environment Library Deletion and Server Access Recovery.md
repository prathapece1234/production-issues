# Chroot Environment Library Deletion and Server Access Recovery

## Incident Summary

A user accidentally deleted critical library files inside a WSO2 chroot environment after accessing the chroot shell. 
After exiting the chroot environment, normal SSH/Putty access to the server failed for all users, resulting in a server access outage.

## Environment

- OS: Ubuntu Linux
- Application: WSO2
- Chroot Path:
  `/home/dev_user/BSS-Deployments/NewCo/chroots/wso2-rootfs`

## User Action Performed

User entered the chroot environment:

chroot /home/dev_user/BSS-Deployments/NewCo/chroots/wso2-rootfs /bin/bash

Critical library files were removed:

rm -rf /home/dev_user/BSS-Deployments/NewCo/chroots/wso2-rootfs/lib/*
rm -rf /home/dev_user/BSS-Deployments/NewCo/chroots/wso2-rootfs/lib64/*

## Symptoms Observed

* WSO2 services failed to start
* Missing runtime libraries
* Chroot environment became unusable
* SSH/Putty login failed for all users
* "Access Denied" errors observed during login
* Normal server administration unavailable

## Root Cause

Critical runtime libraries inside the chroot environment were accidentally deleted. This corrupted the application runtime environment 
and impacted authentication/service dependencies, resulting in failed SSH access and application outages.

## Recovery Process

### Step 1: Impact Assessment

* Verified application failure
* Confirmed SSH login failures for multiple users
* Determined issue originated after library deletion within the chroot environment

### Step 2: Recovery Environment Access

* Booted the server using Ubuntu Live/Try mode
* Mounted the affected filesystem
* Accessed the damaged chroot directories offline

### Step 3: Library Restoration

* Restored missing library directories
* Copied required files into:
  * `/lib`
  * `/lib64`
* Recovered runtime dependencies from a healthy Ubuntu source

### Step 4: Server Recovery

* Verified filesystem integrity
* Rebooted server normally
* Confirmed SSH access restored
* Validated user authentication functionality

### Step 5: Application Validation

* Verified WSO2 environment functionality
* Confirmed services started successfully
* Performed post-recovery validation checks

## Final Outcome

* SSH access restored for all users
* WSO2 environment recovered
* Missing libraries restored successfully
* No application data loss
* Production services returned to normal operation

## Preventive Measures

* Restrict chroot administrative access
* Review commands before execution
* Maintain backups of application environments
* Implement change approval procedures for production systems
* Provide user awareness on chroot operations

## Key Learning

### Major Insights

* Deleting critical libraries inside a chroot can have wider application impacts than expected.
* Runtime library corruption can lead to authentication and service failures.
* Ubuntu Live/Rescue mode is effective for offline recovery of damaged environments.
* Recovery can be completed without rebuilding the server when data remains intact.

## Severity

**Application and Server Access Outage**

## Skills Demonstrated

* Linux administration
* Ubuntu recovery mode operations
* Chroot troubleshooting
* Library restoration
* SSH access recovery
* Production incident management
* Disaster recovery
* Root cause analysis

## Business Impact

* Restored production server accessibility
* Recovered application environment
* Avoided complete server rebuild
* Minimized production downtime
