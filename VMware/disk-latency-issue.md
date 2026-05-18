# Critical ESXi Storage Latency Resolution on Production Data Servers

## Incident Summary
Application and monitoring teams reported multiple production errors across critical services.  
Applications were repeatedly restarted, but the issue persisted without identifying the root cause.

## Initial Symptoms
- Application failures
- Repeated service disruptions
- Multiple application errors
- Monitoring alerts from production environment
- Restart application attempts unsuccessful
- Root cause unclear from application side

## Infrastructure Investigation
During server-side analysis:

### ESXi Findings:
- Data Server 1 latency: **7–10 seconds**
- Data Server 2 latency: **3–4 seconds**

These latency values were critically high for production workloads, causing:
- Slow disk response
- Application timeout
- Database/API failures
- Service instability

## Storage Layer Analysis
### 3PAR Storage:
- Service time significantly elevated
- Initial hardware/storage inspection appeared normal
- No immediate hardware fault detected

## Root Cause Investigation
### Step 1: Path Policy Issue
- Existing storage path policy configured as **MRU (Most Recently Used)**
- Single active path causing throughput bottleneck

### Action:
- Changed policy from **MRU → Round Robin (RR)**

### Result:
- Throughput improved
- Path utilization balanced
- Latency reduced partially
- However, issue not fully resolved

---

### Step 2: Snapshot Analysis
Further investigation identified:
- Multiple old VM snapshots
- Long-standing snapshot chains
- Snapshot overhead creating:
  - Disk pressure
  - Increased I/O wait
  - Storage service time spikes
  - VM performance degradation

## Final Corrective Actions
- Removed obsolete snapshots
- Consolidated VM disks
- Cleaned storage overhead
- Optimized disk chain structure

## Final Outcome
- Storage latency normalized
- VM disk performance restored
- Application stabilized
- Error rates dropped
- Production services fully recovered
- No further critical alerts

## Technical Resolution Summary
### Changes Implemented:
- Storage policy: **MRU → Round Robin**
- Snapshot cleanup
- Disk consolidation
- Throughput optimization
- Storage pressure reduction

---

## Preventive Measures
- Regular snapshot audits
- Avoid long-term snapshot retention
- Monitor ESXi latency proactively
- Review path policies periodically
- Storage service time monitoring
- Application-to-infrastructure correlation checks

## Key Learning
Critical application failures may originate from infrastructure storage bottlenecks rather than application defects.

### Major Insights:
- Storage latency directly impacts application stability
- MRU path policy can create hidden bottlenecks
- Old snapshots significantly degrade VM performance
- Multi-layer troubleshooting (Application → ESXi → Storage) is essential

## Severity
**Production Critical (P1 Incident)**

## Skills Demonstrated
- VMware ESXi troubleshooting
- 3PAR storage analysis
- Multipath optimization
- Snapshot consolidation
- Production incident management
- Cross-team coordination
- Root cause analysis
- Performance optimization
