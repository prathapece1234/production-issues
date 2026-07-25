# Production Webhook Failure Due to DNS SERVFAIL Resolution

## Incident Summary

A production application failed to deliver webhook notifications for mobile number portability and activation events. The application logs reported 
a `java.net.UnknownHostException`, indicating that the destination hostname could not be resolved.

Although the webhook endpoint was reachable from external networks, the application server was unable to resolve the hostname using its configured 
DNS server. Investigation identified that the internal DNS server was returning **SERVFAIL** for the external domain. The issue was resolved by 
enabling a public DNS resolver on the application server, restoring successful DNS resolution and webhook delivery.

---

## Initial Symptoms

* Webhook notifications failed.
* Mobile number portability requests could not be processed.
* Activation notifications were not delivered.
* Application logs reported `java.net.UnknownHostException`.
* Destination hostname unresolved from the application server.
* Service impact reported by the business team.

---

## Investigation

### Initial Findings

Application logs contained the following exception:

```text
java.net.UnknownHostException
```

indicating a DNS name resolution failure.

### Step 1: Verify DNS Resolution

Checked hostname resolution from the application server.

```bash
dig crm-api.prod.yomobile.pub
```

Result:

```text
status: SERVFAIL
```

The configured DNS server failed to resolve the hostname.

### Step 2: Validate External DNS

Tested the same hostname using a public DNS resolver.

```bash
dig @8.8.8.8 crm-api.prod.yomobile.pub
```

Result:

```text
NOERROR
54.xxx.xxx.xxx
```

The hostname resolved successfully.

### Step 3: Verify Server DNS Configuration

Reviewed the resolver configuration.

```bash
cat /etc/resolv.conf
```

Observed that the application server was configured to use only the internal DNS server.

Compared the configuration with another production server, where a public DNS resolver was configured and hostname resolution succeeded.

### Step 4: Network Validation

Worked with the Network team to verify firewall rules and outbound connectivity.

The Network team confirmed:

* No firewall restrictions.
* No recent network changes.
* Required outbound access already permitted.

This ruled out a network connectivity issue.

---

## Root Cause

### Primary Issue

The configured internal DNS server returned **SERVFAIL** when resolving the external webhook domain.

Because the application server relied solely on this DNS server, hostname resolution failed, resulting in application connection failures.

### Technical Cause

* Internal DNS server unable to resolve the external domain.
* Application server depended exclusively on the internal DNS resolver.
* Public DNS successfully resolved the hostname.
* DNS failure generated `UnknownHostException` within the Java application.

---

## Resolution Process

### Step 1: Verify DNS Behaviour

Confirmed the hostname failed using the configured internal DNS server but resolved successfully through a public DNS server.

### Step 2: Update DNS Configuration

Enabled a public DNS resolver on the application server.

The application was then able to resolve the webhook endpoint successfully.

### Step 3: Validation

Verified:

```bash
dig crm-api.prod.yomobile.pub

nslookup crm-api.prod.yomobile.pub
```

Confirmed successful hostname resolution.

### Step 4: Application Validation

Triggered webhook processing.

Verified:

* Successful DNS resolution.
* Webhook delivery restored.
* Application connected successfully to the remote endpoint.
* Business confirmed normal processing of portability and activation requests.

---

## Final Outcome

* DNS resolution restored.
* Webhook notifications resumed successfully.
* Mobile number portability processing restored.
* No application changes required.
* Business operations returned to normal.

---

## Preventive Measures

* Validate DNS resolution before investigating application connectivity.
* Configure appropriate fallback or secondary DNS resolvers where permitted by organisational policy.
* Monitor DNS resolution failures on production servers.
* Periodically verify external domain resolution from application hosts.
* Include DNS validation in application health checks.

---

## Key Learning

### Major Insights

* `UnknownHostException` is often a DNS resolution issue rather than an application defect.
* A `SERVFAIL` response indicates that the DNS server failed to complete the query, even though the domain may exist and resolve through another
  resolver.
* Comparing multiple DNS resolvers helps quickly isolate whether the issue lies with the DNS infrastructure or the destination service.
* Coordinating with network and application teams helps eliminate firewall and connectivity issues, allowing faster identification of DNS-related
  failures.

---

## Severity

**Production Application – Critical DNS Resolution Failure**

---

## Skills Demonstrated

* Linux System Administration
* DNS Troubleshooting
* BIND DNS Diagnostics
* Java Application Support
* Network Connectivity Validation
* Root Cause Analysis (RCA)
* Webhook Troubleshooting
* Production Incident Management
* Cross-Team Collaboration

---

## Business Impact

* Restored webhook communication for production services.
* Resolved a critical business issue impacting mobile number portability and activation processing.
* Eliminated DNS resolution failures affecting external API communication.
* Reduced service disruption through rapid diagnosis and DNS validation.
* Improved operational procedures for troubleshooting application connectivity issues.

