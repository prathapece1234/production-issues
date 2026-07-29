

# Overview

This documents the design, administration, and operational management of a multi-account AWS infrastructure hosting telecom 
applications across Production, Staging, Testing, and Shared Network environments.

The infrastructure follows environment isolation using separate AWS accounts, dedicated VPCs, private subnets, Amazon EC2 instances, 
Oracle Amazon RDS databases, and segmented IP address planning to ensure security, scalability, and operational efficiency.

---

# High-Level Architecture

```text
                         AWS Organization

                    ┌──────────────────────────┐
                    │     AWS Organization     │
                    └────────────┬─────────────┘
                                 │
        ┌────────────────────────┼────────────────────────┐
        │                        │                        │
        │                        │                        │
 Production Account      Staging Account         Testing Account
 10.63.0.0/20             10.63.16.0/20          10.63.32.0/20
        │                        │                        │
        │                        │                        │
   Oracle RDS              Oracle RDS             EC2 Only
   EC2 Fleet               EC2 Fleet             Application Testing
        │                        │
        └──────────────┬─────────┘
                       │
               Shared Network Account
                  10.63.48.0/20
```

---

# AWS Accounts

| Environment | Purpose                            |
| ----------- | ---------------------------------- |
| Production  | Live telecom services              |
| Staging     | Pre-production validation          |
| Testing     | Functional and integration testing |
| Network     | Shared networking services         |

---

# VPC Design

| Account    | CIDR          |
| ---------- | ------------- |
| Production | 10.63.0.0/20  |
| Staging    | 10.63.16.0/20 |
| Testing    | 10.63.32.0/20 |
| Network    | 10.63.48.0/20 |

Each environment is isolated using dedicated AWS accounts and VPCs to prevent unintended access between environments while simplifying 
operational management.

---

# Private Subnets

## Production

```
10.63.8.0/24

10.63.9.0/24

10.63.10.0/28

10.63.10.128/26

10.63.11.0/28

10.63.11.128/26
```

---

## Staging

```
10.63.24.0/24

10.63.25.0/24

10.63.18.0/28
```

---

## Testing

```
10.63.40.0/24

10.63.41.0/24
```

---

## Network

```
10.63.56.0/24

10.63.57.0/24
```

---

# Production Infrastructure

Highlights include:

* Approximately 90 EC2 instances
* Oracle RDS databases
* High Availability (A/B node pairs)
* Monitoring servers
* Jump server
* NTP servers
* Middleware
* Telecom core applications

---

# Staging Infrastructure

The staging environment mirrors production and is used for:

* Patch validation
* Application testing
* Upgrade verification
* Configuration validation
* User Acceptance Testing (UAT)
* Database integration testing

Resources include:

* 22 EC2 instances
* 12 Oracle RDS databases
* Middleware
* Telecom applications
* Database connectivity servers

---

# Testing Infrastructure

The testing environment provides isolated infrastructure for development and validation.

Characteristics:

* Dedicated AWS account
* 10 EC2 instances
* No Amazon RDS
* Application-level testing
* Functional validation
* Integration testing

This separation reduces operational risk by preventing test activities from affecting production or staging.

---

# Database Architecture

Production and staging environments utilize managed Oracle Amazon RDS services.

The databases support:

* PCRF
* HLR
* HSS
* SMSC
* Session Database
* Portal Database
* MSPT Database
* Pay Manager
* VRE Database
* DRE Database

Benefits include:

* Automated backups
* Multi-AZ deployment (where configured)
* Storage autoscaling
* Managed patching
* High availability

---

# Network Segmentation

Traffic is logically separated into:

* Management network (MGMT IP)
* Application network (NIP)
* Database subnet
* Monitoring network

This architecture improves:

* Security
* Performance
* Operational management
* Troubleshooting
* Access control

---

# Multiple NIPs

Some telecom servers have multiple **NIP** addresses.

Example:

```
DRA

Management IP

10.63.25.191

Network IP 1

10.63.25.88

Network IP 2

10.63.25.184
```

These additional IPs are typically used for:

* Diameter interfaces
* SS7/SIGTRAN
* Telecom signaling
* Service-specific endpoints
* High Availability
* Multiple application interfaces

In AWS, these are commonly implemented using:

* Secondary private IP addresses
* Multiple Elastic Network Interfaces (ENIs)

---

# IP Planning Strategy

The infrastructure follows structured CIDR allocation using `/20` VPCs, each providing approximately 4,094 usable private IP addresses.

Benefits include:

* Predictable IP allocation
* Simplified subnet management
* Environment isolation
* Reduced overlap risk
* Easier future expansion

---

# Responsibilities

As part of AWS infrastructure operations, responsibilities included:

* EC2 administration
* Oracle RDS monitoring
* VPC management
* Security Group administration
* Route Table validation
* NACL management
* Storage expansion
* Linux administration
* Capacity planning
* Incident response
* CloudWatch monitoring
* SNS alert management
* Patch management
* Infrastructure documentation
* Root Cause Analysis (RCA)

---

# Technologies Used

* Amazon EC2
* Amazon RDS Oracle
* Amazon VPC
* Amazon EBS
* IAM
* CloudWatch
* SNS
* Route Tables
* Network ACL
* Security Groups
* Amazon Linux
* RHEL
* Oracle 19c

---

# Outcome

Successfully managed a **multi-account AWS telecom infrastructure** comprising production, staging, testing, and shared networking 
environments. The architecture ensured strong environment isolation, standardized IP addressing, high availability, secure network 
segmentation, and scalable infrastructure capable of supporting mission-critical telecom workloads with minimal operational risk.

