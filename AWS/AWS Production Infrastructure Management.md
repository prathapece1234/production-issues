# AWS Production Infrastructure Management

## Overview

This repository documents the management, administration, monitoring, optimization, and operational support of a large-scale production 
AWS infrastructure hosting mission-critical telecom applications.

The environment consists of more than **100+ Amazon EC2 instances**, Oracle RDS databases, monitoring servers, jump servers, and highly 
available application nodes distributed across multiple Availability Zones.

Daily operational responsibilities included Linux administration, storage management, performance tuning, monitoring, incident response, 
capacity planning, patch management, backup verification, and production troubleshooting.

---

# Production Architecture

```text
                    Internet / MPLS
                           │
                    AWS VPC (Production)
                           │
     ┌────────────────────────────────────────────┐
     │                                            │
 Availability Zone A                     Availability Zone B
     │                                            │
 AMS/XML-1                              AMS/XML-2
 DCCS-Gy-01A                            DCCS-Gy-03B
 DRA_1A                                DRA_1B
 OCS-NEW-1                             OCS-NEW-2
 PCRF-1A                               PCRF-2A
 MW1                                   MW2
 Monitoring-1                          Monitoring-2
 NTP-1A                               NTP-2B
     │                                    │
     └──────────────Oracle RDS─────────────┘
                     Multi-AZ
```

---

# Environment

## Cloud Platform

* Amazon Web Services

## Compute

* Amazon EC2

## Database

* Amazon RDS Oracle Enterprise Edition

## Operating Systems

* RHEL 7.5
* RHEL 8.4
* RHEL 8.8
* RHEL 9.3
* RHEL 9.4
* Amazon Linux

## Instance Families

* M6i
* R6i
* C6i
* M5
* M4
* C5
* T2

---

# Objectives

* Maintain production availability
* Ensure high availability
* Monitor system health
* Manage storage
* Handle production incidents
* Perform patching
* Capacity planning
* OS administration
* Infrastructure troubleshooting

---

# Responsibilities

## EC2 Administration

Managed more than 100 production EC2 instances.

Activities included

* Instance health monitoring
* CPU utilization monitoring
* Memory monitoring
* Disk utilization
* EBS expansion
* Volume management
* Service management
* Kernel updates
* Package updates
* User administration
* SSH management

---

## Storage Management

Managed multiple EBS volumes.

Example

```
/
20 GB

/data
390 GB

/apps
50 GB

/loggers
250 GB
```

Performed

* Filesystem expansion

```
growpart
xfs_growfs
resize2fs
```

Verified

```
lsblk

df -h

pvs

vgs

lvs
```

---

## Linux Administration

Daily administration included

```
systemctl

journalctl

top

vmstat

iostat

sar

ss

netstat

ps

crontab

firewalld
```

---

## Production Monitoring

Monitored

* CPU
* Memory
* Swap
* Load Average
* Disk Usage
* Filesystem
* Network
* Process availability
* Application services

Tools

* Grafana
* OpsRamp
* CloudWatch

---

## High Availability

Most production applications were deployed in Active/Standby architecture.

Examples

```
OCS-NEW-1
OCS-NEW-2

MW1
MW2

PCRF-1A
PCRF-2A

USSD-1
USSD-2

Monitoring-1
Monitoring-2
```

Benefits

* Failover support
* Reduced downtime
* Business continuity

---

## Oracle RDS Management

Managed Oracle RDS instances including

* Health checks
* Storage monitoring
* Performance monitoring
* Backup verification
* Multi-AZ validation
* Connectivity troubleshooting

Example

```
Oracle 19c

Multi-AZ

Provisioned IOPS

Storage Auto Scaling
```

---

## Capacity Planning

Monitored

```
CPU

Memory

Storage

IOPS

Filesystem growth

Database storage

Application utilization
```

Recommended

* Volume expansion
* Instance resizing
* Storage optimization

---

## Security

Performed

* IAM access validation
* Security Group verification
* SSH access management
* OS hardening
* Patch management
* User privilege review

---

## Daily Health Checks

Verified

```
uptime

free -h

df -h

systemctl status

journalctl -xe

aws ec2 describe-instance-status

aws cloudwatch

ping

curl
```

---

## Incident Management

Handled production incidents involving

* Filesystem full
* Application down
* Service failures
* High CPU
* High Memory
* Network issues
* Storage failures
* EC2 recovery
* RDS connectivity
* Application failover

---

# Validation

Verified

```
EC2 Status Checks

Application Availability

Database Connectivity

Filesystem Health

Network Connectivity

Load Average

CloudWatch Metrics

OpsRamp Alerts
```

---

# Best Practices

* Multi-AZ deployment
* Separate application volumes
* Dedicated log filesystem
* Regular patching
* Capacity monitoring
* Backup validation
* Principle of Least Privilege
* CloudWatch monitoring
* High availability architecture
* Standardized server builds

---

# Technologies Used

* Amazon EC2
* Amazon EBS
* Amazon RDS Oracle
* IAM
* Security Groups
* CloudWatch
* Grafana
* OpsRamp
* Amazon Linux
* RHEL
* XFS
* LVM
* SSH

---

# Outcome

Successfully managed a production AWS environment consisting of more than 60 Linux servers hosting telecom applications with high 
availability, Oracle databases, dedicated storage volumes, centralized monitoring, and enterprise operational procedures while 
maintaining service availability and minimizing downtime.


