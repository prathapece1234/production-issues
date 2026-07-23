# Enterprise Linux Operating System Lifecycle Management (RHEL & Ubuntu)

## Project Summary

Performed operating system lifecycle management for Red Hat Enterprise Linux (RHEL) and Ubuntu servers in production and non-production environments.

Activities included:

- Minor version upgrades
- Major version upgrades
- Security patch management
- Subscription management
- Leapp in-place upgrades
- Repository management
- Post-upgrade validation

The objective was to maintain vendor-supported operating systems, improve security posture, and ensure application compatibility with minimal downtime.

---

# Environment

## Red Hat Enterprise Linux

- RHEL 7.x
- RHEL 8.x
- RHEL 9.x

## Ubuntu

- Ubuntu 22.04 LTS
- Ubuntu 24.04 LTS
- Ubuntu 25.04

---

# Scope

Performed:

- Security patch installation
- Minor release upgrades
- Major OS upgrades
- Repository management
- Subscription management
- Kernel updates
- Application validation
- Server reboot planning

---

# Red Hat Enterprise Linux

## Subscription Management

Registered systems using Red Hat Subscription Manager.

Verified:

- Subscription status
- Attached subscriptions
- Enabled repositories

Managed release versions using:

```bash
subscription-manager release --set=9.3
```

or

```bash
subscription-manager release --set=9.6
```

This ensured systems remained on the required minor release before scheduled upgrades.

---

## Security Patching

Installed security updates using DNF.

Example:

```bash
dnf update --security
```

Verified installed security advisories after patching.

---

## Minor Version Upgrade

Performed in-place upgrades between RHEL minor releases.

Example:

```
RHEL 9.3
      ↓
RHEL 9.8
```

Procedure:

```bash
dnf clean all
dnf upgrade --refresh
dnf update
reboot
```

Validation performed:

- OS version
- Kernel version
- Running services
- Application functionality

---

## Major Version Upgrade

Performed in-place operating system upgrades using Leapp.

Upgrade path:

```
RHEL 7
   ↓
Leapp Preupgrade

RHEL 8
   ↓
Leapp Upgrade

RHEL 9
```

### Pre-upgrade Activities

- Verified supported hardware
- Checked repositories
- Validated application compatibility
- Created server backup
- Reviewed Leapp pre-upgrade report

Executed:

```bash
leapp preupgrade
```

Resolved reported inhibitors before proceeding.

Performed upgrade:

```bash
leapp upgrade
```

Rebooted into the upgraded operating system.

Repeated the same process for:

```
RHEL 8 → RHEL 9
```

---

# Ubuntu Lifecycle Management

Performed operating system upgrades following Canonical's supported upgrade path.

Example:

```
Ubuntu 22.04 LTS
          ↓
Ubuntu 24.04 LTS
          ↓
Ubuntu 25.04
```

Direct upgrades across unsupported releases were avoided.

Updated packages using:

```bash
apt update
apt upgrade
apt full-upgrade
```

Performed release upgrades using Ubuntu's recommended upgrade process.

---

# Post-Upgrade Validation

Verified:

- Operating system version
- Kernel version
- Repository status
- Running services
- Network connectivity
- Mounted filesystems
- Application health
- Database connectivity
- System logs

Reviewed:

```bash
journalctl
```

Verified:

```bash
systemctl --failed
```

No critical service failures were observed after upgrades.

---

# Rollback Preparation

Before each upgrade:

- Verified server backups
- Confirmed snapshot availability (virtual machines)
- Scheduled maintenance window
- Documented rollback procedures
- Notified application owners

---

# Result

Successfully completed:

### Red Hat Enterprise Linux

- Security patch installation
- Minor version upgrades
- Major version upgrades
- Subscription management
- Repository management

### Ubuntu

- Security updates
- Minor package upgrades
- Major release upgrades
- LTS migration

All servers were successfully upgraded and validated without application issues.

---

# Technologies Used

- Red Hat Enterprise Linux
- Ubuntu Linux
- Red Hat Subscription Manager
- DNF
- APT
- Leapp
- Systemd
- Linux Kernel
- Enterprise Linux Administration
- OS Lifecycle Management
- Security Patch Management

---

# Key Learnings

- Use Red Hat Subscription Manager to control supported minor releases before upgrades.
- Always perform Leapp pre-upgrade analysis and resolve inhibitors before major version upgrades.
- Follow the vendor-supported upgrade path for Ubuntu and avoid unsupported direct version jumps.
- Validate application and service health after every upgrade.
- Maintain backups and rollback plans before applying operating system updates.
- Regular patching and lifecycle management improve system security, stability, and vendor support compliance.
