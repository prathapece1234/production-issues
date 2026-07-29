# AWS Enterprise Telecom Production Platform

## Overview

This repository documents the design, deployment, administration, security, monitoring, and operational management of a production-grade 
telecom platform hosted on Amazon Web Services (AWS).

The environment follows AWS Well-Architected Framework principles by implementing a secure multi-tier architecture with private 
networking, Application Load Balancer (ALB), Bastion Host access, Oracle and PostgreSQL databases, Amazon Inspector vulnerability 
management, Amazon GuardDuty threat detection, CloudWatch monitoring, AWS KMS encryption, and highly available application services.

The platform supports mission-critical telecom applications including REST APIs, SMPP services, CDR processing, reconciliation services, 
Oracle databases, PostgreSQL databases, and middleware components while maintaining strict security and network isolation.

---

# Architecture

## High-Level Architecture

```text
                    Internet
                        │
                Internet Gateway
                        │
        Application Load Balancer (ALB)
                        │
        ┌───────────────┴───────────────┐
        │                               │
  Private Subnet AZ-1             Private Subnet AZ-2
        │                               │
  Java Application-1             Java Application-2
        │                               │
        └──────────────┬────────────────┘
                       │
             Oracle & PostgreSQL
                       │
                 NAT Gateway
                       │
                  External APIs
```

---

# Environment

| Component                | Details                    |
| ------------------------ | -------------------------- |
| Cloud Provider           | Amazon Web Services        |
| Region                   | ap-southeast-5 (Malaysia)  |
| Architecture             | Multi-tier                 |
| Availability Zones       | 3                          |
| VPC CIDR                 | 172.21.0.0/20              |
| Public Subnets           | 3                          |
| Private Subnets          | 3                          |
| Bastion Host             | Yes                        |
| Load Balancer            | Application Load Balancer  |
| NAT Gateway              | Yes                        |
| Storage                  | Amazon EBS (KMS Encrypted) |
| Monitoring               | Amazon CloudWatch          |
| Threat Detection         | Amazon GuardDuty           |
| Vulnerability Assessment | Amazon Inspector           |

---

# Objectives

* Build a secure production environment.
* Isolate application and database workloads.
* Provide secure administrative access through a Bastion Host.
* Support highly available telecom services.
* Enable secure outbound connectivity for private workloads.
* Implement continuous monitoring and alerting.
* Detect vulnerabilities and security threats proactively.
* Encrypt storage and protect sensitive workloads.

---

# Architecture Components

## Networking

* Amazon VPC
* Internet Gateway
* NAT Gateway
* Public Subnets
* Private Subnets
* Route Tables
* Security Groups
* Network ACLs

---

## Compute

* Bastion Host
* Java Application Servers
* Oracle Database Server
* PostgreSQL Database
* Backup/CDR Server
* CDR Reconciliation Server

---

## Storage

* Amazon EBS
* AWS KMS Encryption

---

## Load Balancing

Application Load Balancer distributes inbound API requests across multiple application servers deployed in private subnets, providing 
high availability and health-based routing.

---

# Network Design

## VPC

```text
172.21.0.0/20
```

## Public Subnets

```text
AZ-1A

172.21.1.0/24

AZ-1B

172.21.2.0/24

AZ-1C

172.21.3.0/24
```

## Private Subnets

```text
AZ-1A

172.21.4.0/24

AZ-1B

172.21.5.0/24

AZ-1C

172.21.6.0/24
```

---

# Traffic Flow

## Inbound Traffic

```text
Internet
        ↓
Internet Gateway
        ↓
Application Load Balancer
        ↓
Private Application Servers
```

## Outbound Traffic

```text
Private EC2
        ↓
Private Route Table
        ↓
NAT Gateway
        ↓
Internet Gateway
        ↓
External APIs / SMPP Services
```

---

# Bastion Host Architecture

All production Linux servers reside in private subnets and do not have public IP addresses.

Administrative access is only possible through the Bastion Host.

```text
Administrator

       │

Office Network

       │

SSH (TCP 22)

       │

Bastion Host

       │

SSH

       │

Private Servers
```

Example:

```bash
ssh ubuntu@<bastion-public-ip>

ssh xius-java-app1
ssh xius-java-app2
ssh xius-postgresql
ssh xius-oracle
ssh xius-bkp-cdr
ssh xius-cdr-recon
```

---

# Access Control

SSH access is restricted using Security Groups.

Example:

```text
Allowed Source

103.5.70.19/32
```

Only whitelisted office networks are permitted to access the Bastion Host.

Private application and database servers cannot be accessed directly from the Internet.

---

# Security Architecture

The environment follows a layered security model.

### Network Security

* Private Subnets
* Security Groups
* Network ACLs
* Bastion-only administration
* Restricted SSH access

### Identity & Access

* IAM Roles
* Least Privilege Access
* SSH Key Authentication

### Data Protection

* AWS KMS encrypted EBS volumes
* Encrypted SSH communication

---

# Amazon Inspector

Amazon Inspector provides continuous vulnerability assessment for Amazon EC2 instances.

### Responsibilities

* Operating system vulnerability scanning
* CVE identification
* Security recommendations
* Continuous package assessment
* Exposure analysis

### Benefits

* Continuous security assessment
* Automated vulnerability detection
* Reduced security risk
* Compliance support

---

# Amazon GuardDuty

Amazon GuardDuty continuously monitors the AWS environment for suspicious and malicious activity.

### Detects

* SSH brute-force attacks
* Port scanning
* Credential compromise
* Suspicious API activity
* Unusual IAM behaviour
* Malware indicators
* Cryptocurrency mining
* Data exfiltration attempts

### Data Sources

* AWS CloudTrail
* VPC Flow Logs
* DNS Logs

### Benefits

* Continuous threat detection
* Faster incident response
* Behaviour-based analysis
* Centralised security findings

---

# Amazon CloudWatch

CloudWatch provides infrastructure monitoring, logging, and operational visibility.

### Monitored Resources

* EC2 Instances
* Application Load Balancer
* NAT Gateway
* Amazon EBS
* Oracle Database
* PostgreSQL Database
* Memory
* CPU
* Disk Usage
* Network Traffic

### Alarms

Examples:

```text
CPU Utilization ≥ 80%

Memory Utilization > 80%

Disk Usage > 70%

EC2 Status Check Failed

Application Health

Database Health
```

### Notifications

```text
CloudWatch

↓

CloudWatch Alarm

↓

Amazon SNS

↓

Operations Team
```

---

# AWS KMS

AWS Key Management Service secures encrypted storage across the environment.

Encrypted resources include:

* Amazon EBS volumes
* Snapshots
* Database storage

---

# AWS CloudTrail

CloudTrail records all management events and API activity.

Typical events include:

* EC2 lifecycle operations
* Security Group changes
* IAM updates
* VPC configuration changes
* Route Table modifications
* Key Pair usage

CloudTrail logs complement GuardDuty by providing audit visibility for investigations.

---

# Instance Inventory

Production environment includes:

* Bastion Host
* Java Application Servers
* Oracle Database
* PostgreSQL Database
* Backup/CDR Server
* CDR Reconciliation Server

| Resource      |  Count |
| ------------- | -----: |
| EC2 Instances |      7 |
| Total vCPUs   |     62 |
| Total Memory  | 370 GB |
| Total Storage | 6.6 TB |

---

# Validation

Infrastructure validation included:

```bash
aws ec2 describe-instances

aws ec2 describe-route-tables

aws ec2 describe-security-groups

aws ec2 describe-subnets

aws ec2 describe-nat-gateways

aws ec2 describe-vpcs
```

Connectivity validation:

```bash
ssh xius-bastion

ssh xius-java-app1

ssh xius-java-app2

ssh xius-postgresql

curl http://localhost

ping

nc
```

Security validation:

* Verified Inspector findings
* Reviewed GuardDuty findings
* Confirmed CloudWatch alarms
* Verified Security Group rules
* Tested Bastion-only SSH access
* Validated encrypted EBS volumes

---

# Best Practices

* Multi-AZ deployment for high availability
* Private subnet isolation for critical workloads
* Bastion-only administrative access
* Security Group least-privilege rules
* Encrypted EBS volumes using AWS KMS
* Continuous vulnerability scanning with Amazon Inspector
* Continuous threat monitoring with Amazon GuardDuty
* Infrastructure monitoring using Amazon CloudWatch
* API audit logging using AWS CloudTrail
* Principle of Least Privilege for IAM access
* SSH key-based authentication
* Regular patching and vulnerability remediation

---

# Challenges

* Designing secure administrative access without exposing private servers.
* Supporting outbound Internet connectivity while keeping workloads private.
* Balancing high availability with network isolation.
* Protecting telecom workloads against infrastructure and application threats.
* Implementing continuous monitoring and security visibility across production resources.

---

# Outcome

Successfully designed, deployed, and managed a secure production AWS telecom platform using a multi-tier architecture with private 
networking, Application Load Balancer, Bastion Host administration, encrypted storage, Oracle and PostgreSQL databases, continuous 
infrastructure monitoring, vulnerability assessment through Amazon Inspector, threat detection using Amazon GuardDuty, and comprehensive 
operational visibility with Amazon CloudWatch and AWS CloudTrail. The architecture provides high availability, strong security controls, 
controlled administrative access, and reliable support for mission-critical telecom services.

---

# Technologies Used

* Amazon EC2
* Amazon VPC
* Internet Gateway
* NAT Gateway
* Application Load Balancer
* Amazon EBS
* Amazon CloudWatch
* Amazon Inspector
* Amazon GuardDuty
* AWS CloudTrail
* AWS KMS
* IAM
* Security Groups
* Network ACLs
* Oracle Database
* PostgreSQL
* Ubuntu
* RHEL
* OpenSSH

---
