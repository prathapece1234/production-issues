# BIND9 Delegation to Kubernetes CoreDNS for Internal DNS Resolution

## Incident Summary

An internal Kubernetes environment hosted CoreDNS for application-specific DNS records under the following zones:

- `dev.xius.com`
- `dev.k8s.xius.com`

The enterprise DNS server (BIND 9.11 on RHEL 7) was authoritative for the parent zone:
xius.com

The objective was to allow all requests for:

*.dev.xius.com
*.dev.k8s.xius.com

to be resolved by Kubernetes CoreDNS running at:
192.168.149.81


---

## Environment

| Component | Details |
|-----------|---------|
| DNS Server | BIND 9.11 |
| OS | RHEL 7.8 |
| Parent Zone | xius.com |
| CoreDNS | Kubernetes CoreDNS |
| CoreDNS IP | 192.168.149.81 |
| Parent DNS | 192.168.149.155 |
| Windows DNS | Conditional Forwarder → 192.168.149.155 |

---

## Initial Configuration

BIND was configured with conditional forwarding.

```conf
zone "dev.xius.com" {
    type forward;
    forward only;
    forwarders { 192.168.149.81; };
};

zone "dev.k8s.xius.com" {
    type forward;
    forward only;
    forwarders { 192.168.149.81; };
};
```

The parent authoritative zone was configured as:

```conf
zone "xius.com" {
    type master;
    file "forward.xius";
};
```

---

## Symptoms

Queries returned:

```
SERVFAIL
```

or

```
NXDOMAIN
```

Windows DNS also timed out after cache clearing.

Example:

```bash
dig @127.0.0.1 harbor.dev.k8s.xius.com

status: SERVFAIL
```

---

## Investigation

### Verified CoreDNS

```bash
dig @192.168.149.81 harbor.dev.k8s.xius.com
```

Output

```
NOERROR

192.168.149.26
```

CoreDNS was functioning correctly.

---

### Verified Parent DNS

```bash
dig @127.0.0.1 harbor.dev.k8s.xius.com
```

Output

```
SERVFAIL
```

---

### Packet Capture

```
tcpdump -ni any port 53
```

Observed

```
Windows DNS
        ↓
Linux BIND

Linux BIND
        ↓
SERVFAIL
```

No network issue existed.

---

### DNSSEC Validation Test

```
dig @127.0.0.1 harbor.dev.k8s.xius.com +cd
```

Output

```
NOERROR

192.168.149.26
```

The `+cd` option disables DNSSEC validation.

Since the query succeeded only with `+cd`, the issue was confirmed to be DNSSEC validation.

---

## Root Cause

The BIND server was:

- Authoritative for `xius.com`
- Configured with child forward zones
- Performing DNSSEC validation
- Located in an isolated internal environment without Internet connectivity

Configuration:

```conf
dnssec-enable yes;
dnssec-validation yes;
```

Because the server could not build a DNSSEC trust chain, BIND returned:

```
SERVFAIL
```

for delegated internal zones.

---

## Resolution

### Removed Conditional Forward Zones

Removed:

```conf
zone "dev.xius.com" {
    type forward;
}

zone "dev.k8s.xius.com" {
    type forward;
}
```

---

### Configured Proper DNS Delegation

Added to the authoritative zone file:

```dns
dev             IN NS ns-dev.xius.com.
ns-dev          IN A 192.168.149.81

dev.k8s         IN NS ns-k8s.xius.com.
ns-k8s          IN A 192.168.149.81
```

Reloaded DNS:

```bash
named-checkconf
named-checkzone xius.com /var/named/forward.xius
rndc reload
rndc flush
```

---

### Disable DNSSEC Validation (Internal DNS)

```conf
dnssec-validation no;
```

Reload:

```bash
rndc reload
```

---

## Verification

Linux

```bash
dig @127.0.0.1 harbor.dev.k8s.xius.com
```

Result

```
NOERROR

192.168.149.26
```

Windows

```cmd
nslookup harbor.dev.k8s.xius.com
```

Resolved successfully.

---

## DNS Flow

```
Windows Client
        │
        ▼
Windows DNS
Conditional Forwarder
        │
        ▼
BIND DNS (192.168.149.155)
Authoritative for xius.com
        │
        │ Delegation
        ▼
CoreDNS (192.168.149.81)
        │
        ▼
harbor.dev.k8s.xius.com
192.168.149.26
```

---

## Useful Commands

Validate configuration

```bash
named-checkconf
named-checkzone xius.com /var/named/forward.xius
```

Reload

```bash
rndc reload
rndc flush
```

Packet Capture

```bash
tcpdump -ni any port 53
```

Query

```bash
dig @127.0.0.1 harbor.dev.k8s.xius.com
```

DNSSEC Test

```bash
dig @127.0.0.1 harbor.dev.k8s.xius.com +cd
```

CoreDNS

```bash
dig @192.168.149.81 harbor.dev.k8s.xius.com
```

---

## Lessons Learned

- Do not use conditional forwarding for child zones of an authoritative zone on the same BIND server.
- Use **NS delegation** when another authoritative DNS server (CoreDNS) owns a subdomain.
- Internal DNS environments without Internet access should carefully evaluate whether DNSSEC validation is appropriate.
- The `+cd` option in `dig` is an effective way to identify DNSSEC-related failures.
- `tcpdump` is valuable for distinguishing between network connectivity issues and DNS server processing errors.

---

## Keywords

BIND9, CoreDNS, Kubernetes DNS, DNS Delegation, Conditional Forwarding, Internal DNS, DNSSEC, SERVFAIL, NS Delegation, RHEL 7, Linux DNS, Windows DNS, Production Incident
