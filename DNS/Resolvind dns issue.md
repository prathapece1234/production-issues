**Resolving DNS Name Resolution Failure Preventing Internet Package Downloads**

## Overview

A Linux server (**192.168.149.102**) had internet connectivity, but package installations and library downloads were failing. Initial testing 
confirmed that outbound network connectivity was available; however, hostname resolution was not functioning because no valid DNS nameserver was 
configured.

The issue was resolved by updating the DNS configuration in **`/etc/resolv.conf`**, after which hostname resolution and package downloads worked 
successfully.

---

## Environment

| Component        | Details                                  |
| ---------------- | ---------------------------------------- |
| Operating System | Red Hat Enterprise Linux                 |
| Server           | 192.168.149.102                          |
| Issue            | DNS Name Resolution Failure              |
| Affected Service | Package Installation / Library Downloads |

---

## Problem Statement

The application team reported that although internet access had been provided to the server, they were unable to download required libraries or 
install packages.

Testing hostname resolution returned the following error:

```text
ping google.com
ping: google.com: Temporary failure in name resolution
```

Since package managers rely on DNS to resolve repository hostnames, downloads could not proceed.

---

## Investigation

Verified DNS resolution.

```bash
ping google.com
```

Observed:

```text
Temporary failure in name resolution
```

Verified connectivity using an IP address.

```bash
ping 8.8.8.8
```

The IP address was reachable, confirming that network connectivity was working and the issue was isolated to DNS resolution.

Checked the DNS configuration.

```bash
cat /etc/resolv.conf
```

Found that the required nameserver entries were missing or incorrectly configured.

---

## Root Cause

The server had outbound internet connectivity, but **`/etc/resolv.conf`** did not contain a valid DNS nameserver configuration. As a result, 
hostname resolution failed, preventing package managers and applications from resolving external repository hostnames.

---

## Resolution

Configured the appropriate DNS nameserver entries in **`/etc/resolv.conf`**.

Example:

```text
nameserver <DNS_Server_1>
nameserver <DNS_Server_2>
```

Verified the updated configuration.

```bash
cat /etc/resolv.conf
```

Validated DNS resolution.

```bash
ping google.com
```

Successfully installed/downloaded the required libraries after DNS resolution was restored.

---

## Validation

Verified:

* DNS hostname resolution working successfully.
* External domain names resolved correctly.
* Internet connectivity confirmed.
* Package repositories became reachable.
* Required libraries downloaded successfully.

---

## Outcome

* Restored DNS name resolution on the server.
* Resolved package download failures.
* Enabled successful installation of required libraries.
* Confirmed the application team could continue their deployment without further issues.

---

## Technologies Used

* Red Hat Enterprise Linux
* DNS
* `/etc/resolv.conf`
* ICMP (`ping`)
* Linux Networking
* Package Management

---

## Key Learning

Successful internet connectivity does not guarantee that package installations will work. DNS configuration is equally important, as package 
managers depend on hostname resolution to reach external repositories. Verifying connectivity using both an IP address and a hostname helps quickly 
distinguish between network routing issues and DNS configuration problems.
