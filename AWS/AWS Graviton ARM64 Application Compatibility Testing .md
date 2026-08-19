# AWS Graviton ARM64 Application Compatibility Testing

## Overview

Three AWS Graviton-based servers were deployed with **RHEL 9.5** for application compatibility and deployment testing on the 
**ARM64/AArch64 architecture**.

The environment was created to validate whether the existing **APP, WEB and Nginx application stack** can run successfully on Graviton 
processors before considering wider adoption.

## Test Environment

| Server              | Role               | IP Address    | OS       | Architecture |
| ------------------- | ------------------ | ------------- | -------- | ------------ |
| `GRAVITON_APP`   | Application Server | `10.63.18.14` | RHEL 9.5 | ARM64        |
| `GRAVITON_WEB`   | Web Server         | `10.63.18.8`  | RHEL 9.5 | ARM64        |
| `GRAVITON_NGNIX` | Nginx Server       | `10.63.18.11` | RHEL 9.5 | ARM64        |

Application login user:

```text
jboss
```

---

## Why Graviton Testing Was Required

The existing application environment was based on conventional server architecture, so before moving workloads to AWS Graviton, 
application compatibility had to be validated.

The testing was performed to identify:

* ARM64 application compatibility issues
* x86-specific binaries or libraries
* Java/JBoss compatibility
* Nginx compatibility
* Application dependency compatibility
* Application startup and runtime issues
* Network and application connectivity issues
* Performance differences between architectures
* Production migration readiness

The goal was to avoid directly migrating production workloads without first validating the complete application stack on ARM64.

---

## Architecture

```text
                 Application / Test Traffic
                           |
                           v
                    GRAVITON_NGNIX
                     10.63.18.11
                           |
                           v
                     GRAVITON_WEB
                     10.63.18.8
                           |
                           v
                     GRAVITON_APP
                     10.63.18.14
                           |
                           v
                    Application
                           |
                   RHEL 9.5 ARM64
                           |
                    AWS Graviton
```

---

## Implementation

AWS Graviton EC2 VM Creation

1. Open AWS EC2 Console

Navigate to:

AWS Console
   ↓
EC2
   ↓
Instances
   ↓
Launch Instance

The instances were created in the dedicated testing environment for validating application compatibility with AWS Graviton processors.

2. Select AMI

Under Application and OS Images (AMI), select:

Red Hat Enterprise Linux 9.5

The selected AMI must support the ARM64 architecture because the target instances use AWS Graviton processors.

Verify that the AMI architecture is:

arm64
3. Select Graviton Instance Type

Under Instance type, select an AWS Graviton-based instance type suitable for the workload.

For example:

Instance Type: Graviton-based EC2
Architecture: ARM64

Verify that the selected instance type supports:

Architecture: arm64

The instance type should be selected based on the CPU and memory requirements of the application being tested.

### 1. OS Validation

```bash
cat /etc/redhat-release
```

Validated that the servers were running:

```text
Red Hat Enterprise Linux 9.5
```

### 2. Architecture Validation

```bash
uname -m
```

Expected:

```text
aarch64
```

Additional validation:

```bash
lscpu
```

This confirmed that the deployed servers were running on the ARM64 architecture.

---

## 3. Application User Validation

Application access was provided through the `jboss` user.

```bash
id jboss
```

```bash
su - jboss
```

Validated:

```bash
whoami
```

Expected:

```text
jboss
```

---

## 4. Application Compatibility Testing

The application stack was validated on the Graviton environment for:

```text
Application Startup
       |
       v
Java / JBoss
       |
       v
Application Dependencies
       |
       v
Web Layer
       |
       v
Nginx
       |
       v
Network Connectivity
```

Testing included:

* Application startup/shutdown
* Application connectivity
* Web requests
* API functionality
* Java/JBoss runtime
* Application logs
* Dependency validation
* Service restart
* Network connectivity

---

## 5. Nginx Validation

Checked Nginx installation:

```bash
nginx -v
```

Validated configuration:

```bash
nginx -t
```

Checked service:

```bash
systemctl status nginx
```

Checked listening ports:

```bash
ss -lntp | grep nginx
```

---

## 6. Java/JBoss Validation

Validated Java runtime:

```bash
java -version
```

Checked application process:

```bash
ps -ef | grep -i java
```

Checked application listening ports:

```bash
ss -lntp
```

Tested application locally:

```bash
curl http://localhost:<port>
```

---

## 7. ARM64 Binary and Dependency Validation

Architecture-specific binaries and libraries were checked using:

```bash
file <binary>
```

and:

```bash
readelf -h <binary>
```

The purpose was to identify any dependency that was compiled specifically for `x86_64` and could prevent native execution on ARM64.

---

## 8. Performance Validation

System-level performance was monitored during application testing.

### CPU

```bash
top
```

```bash
mpstat
```

### Memory

```bash
free -h
```

### Disk I/O

```bash
iostat -xz 1
```

### Network

```bash
sar -n DEV 1
```

### Process-level usage

```bash
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head
```

Performance observations can be used later to compare the Graviton environment against the existing production architecture.

---

## 9. Application Log Validation

Application and system logs were monitored during testing:

```bash
journalctl -xe
```

and application-specific logs:

```bash
tail -f <application-log>
```

Particular attention was given to:

```text
Exec format error
Illegal instruction
Library not found
Dependency errors
Segmentation faults
Java/JBoss startup errors
Application runtime failures
```

---

## 10. Migration Readiness

The testing environment provides a controlled platform for evaluating a future migration:

```text
Existing Architecture
        |
        v
Application Compatibility Testing
        |
        v
AWS Graviton ARM64
        |
        +---- Compatible
        |        |
        |        v
        |   Performance Testing
        |        |
        |        v
        |   Migration Planning
        |
        +---- Incompatible
                 |
                 v
          Identify dependency
          / binary limitations
```

---

## Validation Checklist

```text
[✓] Graviton servers provisioned
[✓] RHEL 9.5 deployed
[✓] ARM64 architecture verified
[✓] APP server deployed
[✓] WEB server deployed
[✓] Nginx server deployed
[✓] jboss user access validated
[✓] Java/JBoss compatibility tested
[✓] Nginx configuration validated
[✓] Application connectivity tested
[✓] Application dependencies checked
[✓] ARM64 binary compatibility checked
[✓] CPU and memory monitoring performed
[✓] Disk and network monitoring performed
[✓] Application logs reviewed
[✓] Environment prepared for migration assessment
```

---

## Outcome

Successfully established a **three-server AWS Graviton ARM64 testing environment** using RHEL 9.5 for APP, WEB and Nginx workloads.

The environment provides a controlled platform to:

* Validate application compatibility with ARM64.
* Identify architecture-specific dependencies.
* Test Java/JBoss and Nginx workloads.
* Measure application and infrastructure performance.
* Identify issues before production migration.
* Assess the feasibility of adopting AWS Graviton for future workloads.

---

## Technologies

```text
AWS EC2
AWS Graviton
ARM64 / AArch64
RHEL 9.5
Linux
Java
JBoss
Nginx
Application Deployment
Linux Performance Monitoring
Application Compatibility Testing
Cloud Migration
Infrastructure Testing
```

