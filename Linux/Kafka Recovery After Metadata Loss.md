**Kafka Recovery After Metadata Loss Caused by `/tmp` Cleanup Policy**

## Overview

An application team reported intermittent connectivity failures to the Kafka broker running on **192.168.144.59:9092**. The application logs 
showed repeated **"connection closed by peer"**, **"connection refused"**, and **"1/1 brokers are down"** errors, indicating that the Kafka broker 
was unavailable.

Investigation revealed that Kafka failed to start because the required **`meta.properties`** file was missing from the Kafka log directory. 
The Kafka data directory had been configured under **`/tmp`**, and the operating system's automatic `tmpfiles` cleanup policy had removed the 
metadata after it remained unchanged for more than 10 days.

Since the cluster metadata was permanently lost and this was a **test environment**, the Kafka cluster was re-initialized, and the Kafka storage 
directory was moved to a permanent location under **`/var/lib`** to prevent future occurrences.

---

## Environment

| Component          | Details                   |
| ------------------ | ------------------------- |
| Operating System   | Red Hat Enterprise Linux  |
| Messaging Platform | Apache Kafka (KRaft Mode) |
| Kafka Broker       | 192.168.144.59:9092       |
| Deployment         | Test Environment          |

---

## Problem Statement

The application team reported intermittent failures while connecting to the Kafka broker.

Observed application errors included:

```text
Connection closed by peer

Connection refused

1/1 brokers are down
```

As a result:

* Producers and consumers could not connect.
* Port 9092 was no longer listening.
* Kafka service failed to start.

---

## Investigation

Verified the Kafka service status.

```bash
systemctl status kafka
```

Reviewed Kafka startup logs.

```bash
journalctl -u kafka
```

Verified the configured Kafka log directory.

```bash
grep log.dirs /etc/kafka/server.properties
```

Observed that the Kafka data directory was configured under:

```text
/tmp
```

Checked the Kafka metadata directory.

```bash
ls -l /tmp/kraft-data
```

Verified that the required **`meta.properties`** file was missing.

---

## Root Cause

Kafka was configured to store its KRaft metadata under the **`/tmp`** directory.

The Linux **systemd-tmpfiles** cleanup service automatically removes files in `/tmp` that remain inactive beyond the configured retention period 
(typically 10 days).

Since the **`meta.properties`** file is created only once during Kafka initialization and is not modified during normal operation, it was 
identified as an inactive file and deleted by the cleanup process.

Without the `meta.properties` file:

* Kafka could not identify the cluster.
* Metadata could not be reconstructed automatically.
* The broker failed to start.
* Port **9092** was no longer available for client connections.

---

## Resolution

As this was a **test environment**, a new Kafka cluster was initialized.

Created a permanent storage location.

```bash
mkdir -p /var/lib/kafka/kraft-data
```

Updated the Kafka configuration to use the new storage location.

```properties
log.dirs=/var/lib/kafka/kraft-data
```

Formatted the Kafka storage to generate new cluster metadata.

```bash
kafka-storage.sh format \
  --cluster-id <cluster-id> \
  --config /etc/kafka/server.properties
```

Started the Kafka service.

```bash
systemctl start kafka
systemctl enable kafka
```

Verified the broker was listening.

```bash
ss -lntp | grep 9092
```

Confirmed the newly generated metadata.

```bash
cat /var/lib/kafka/kraft-data/meta.properties
```

Example:

```text
node.id=1
directory.id=xLdt1IWd82e9iG43TMAa6A
version=1
cluster.id=yho47nIeQtywgU0A6DZZlA
```

The application team was informed to reconnect and validate Kafka connectivity.

---

## Validation

Verified:

* Kafka service started successfully.
* Port **9092** was listening.
* New KRaft metadata was created.
* `meta.properties` existed under `/var/lib/kafka/kraft-data`.
* Application successfully connected to the Kafka broker.
* Producer and consumer communication resumed successfully.

---

## Outcome

* Successfully restored Kafka service.
* Re-initialized the Kafka cluster in the test environment.
* Migrated Kafka storage from the temporary filesystem to a permanent location.
* Eliminated the risk of metadata deletion caused by `/tmp` cleanup.
* Restored application connectivity to the Kafka broker.

---

## Technologies Used

* Apache Kafka (KRaft Mode)
* Red Hat Enterprise Linux
* systemd
* systemd-tmpfiles
* Linux Storage Administration
* Kafka Storage Tool
* Linux Networking

---

## Key Learning

Critical application data should never be stored under temporary directories such as **`/tmp`**, as operating system cleanup services may 
automatically remove inactive files. In KRaft mode, the **`meta.properties`** file is essential for identifying the Kafka cluster and cannot be 
recreated once lost. Configuring Kafka to use a persistent location such as **`/var/lib/kafka`** ensures metadata survives reboots and cleanup 
operations, providing a reliable and production-ready deployment.
