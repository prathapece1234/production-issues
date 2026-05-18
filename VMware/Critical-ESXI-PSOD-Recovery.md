# Critical ESXi PSOD Recovery – Production Hypervisor Crash Due to Outdated FC SAN HBA Driver

## Incident Summary
The NOC team initially reported that the monitoring agent (OpsRamp) had gone offline.

## Initial Symptoms
- Monitoring agent unreachable
- Server failed to respond to ping
- Hosted applications inaccessible
- Hypervisor unreachable
- Complete infrastructure outage suspected

## Immediate Investigation
### Validation Steps:
- Ping checks failed
- Hypervisor management inaccessible
- Opened vCenter for infrastructure validation

### vCenter Findings:
- ESXi host showed **orphaned state**
- 5 critical production VMs impacted
- Complete host failure confirmed

---

## Root Cause Identification
### iLO Access:
Accessed physical server remotely through iLO and discovered:

### Primary Cause:
**PSOD (Purple Screen of Death) / Kernel Panic**

This indicated:
- ESXi kernel crash
- Hypervisor-level failure
- Production VM outage
- SAN communication disruption

---

## Immediate Recovery Actions
### Step 1:
- Attempted graceful power off
- Initial shutdown process delayed
- Waited for proper host shutdown

### Step 2:
- Allowed server to fully power off
- Waited 5 seconds for hardware stabilization

### Step 3:
- Powered on ESXi host manually

---

## Recovery Outcome
### Post Boot:
- ESXi host became reachable
- vCenter connectivity restored
- Infrastructure management resumed

### Production Recovery:
- Bulk powered on all 5 production VMs
- Application services restored
- Monitoring resumed
- Operations team informed immediately to validate application services
- Management escalation completed

### Total Recovery Time:
**Under 10 minutes**

---

## Deep Root Cause Analysis
Further investigation revealed:

### FC SAN HBA Driver Issue:
- Outdated FC SAN HBA driver version
- Known firmware/driver bug
- Driver sent improper/unpopulated storage addresses
- SAN storage returned errors
- Faulty driver incorrectly interpreted failed responses as successful
- Invalid status propagation triggered ESXi kernel panic
- Result: PSOD crash

---

## Technical Breakdown
### Failure Chain:
1. Outdated HBA driver
2. Invalid storage address transmission
3. SAN rejection/error
4. Driver misreporting successful status
5. Kernel memory/driver corruption
6. PSOD
7. Hypervisor outage
8. Production VM downtime

---

## Final Resolution
### Corrective Actions:
- Immediate host reboot
- Production VM restoration
- Incident escalation
- Root cause identification
- Planned FC SAN HBA driver upgrade
- Firmware alignment recommendation

---

## Preventive Measures
- Regular ESXi driver audits
- Firmware + driver compatibility validation
- HBA firmware updates
- Proactive PSOD log analysis
- SAN path health checks
- Lifecycle Manager compliance enforcement
- Patch management process

---

## Key Learning
### Major Insights:
- Outdated storage drivers can cause full hypervisor crashes
- Monitoring outages may indicate infrastructure-level failures
- iLO is critical for remote recovery
- Fast hypervisor restoration minimizes business downtime
- Driver/firmware alignment is essential for production stability

---

## Severity
**P1 Critical Production Infrastructure Incident**

---

## Skills Demonstrated
- VMware ESXi incident response
- PSOD troubleshooting
- iLO remote recovery
- vCenter diagnostics
- SAN infrastructure troubleshooting
- FC HBA driver analysis
- Kernel panic recovery
- Production outage management
- Cross-team communication
- Root cause analysis

---

## Business Impact
- Prevented extended downtime
- Restored 5 production workloads rapidly
- Reduced customer impact
- Maintained operational continuity
- Improved future infrastructure resilience
