# VMFS Datastore Size Not Updating After Dell ME5 LUN Expansion

## Incident Summary

A Dell ME5 iSCSI LUN backing a shared VMFS datastore was expanded by approximately 150 GB. While some ESXi hosts immediately reflected 
the new capacity, one host continued showing the old datastore size despite detecting the updated LUN size.

## Environment

- Hypervisor: VMware ESXi
- Storage: Dell ME5
- Protocol: iSCSI
- Datastore: ME5-Datastore01
- Shared Across:
  - ESXi4
  - ESXi5
  - ESXi6

## Symptoms Observed

After storage expansion:

### ESXi5 and ESXi6

Datastore Size: 4.59 TB

### ESXi4

Datastore Size: 4.46 TB

Although all hosts were connected to the same shared datastore, ESXi4 continued displaying the old capacity.

## Investigation

### Verify Datastore Size

esxcli storage filesystem list

Observed:

### ESXi4

ME5-Datastore01
Size: 4899752378368

### ESXi5 / ESXi6

ME5-Datastore01
Size: 5049807798272

Difference: 150,055,419,904 bytes (~150 GB)

### Verify VMFS Extent

Executed:

esxcli storage vmfs extent list
All hosts reported:

ME5-Datastore01
naa.600c0ff000fdbdbde267b46701000000
Partition 1


Confirmed:
- Same datastore UUID
- Same backing device
- Same partition

### Verify LUN Size

Executed:
esxcli storage core device list -d naa.600c0ff000fdbdbde267b46701000000

All hosts reported:
Size: 4816044

This confirmed:

- Dell ME5 expansion completed successfully
- iSCSI presentation healthy
- LUN size visible on all hosts
- Issue isolated to VMFS metadata visibility

---

## Root Cause

ESXi4 detected the expanded LUN size but retained stale VMFS metadata information.

As a result:
- Device size refreshed correctly
- VMFS filesystem view remained outdated
- Datastore capacity displayed incorrectly

---

## Resolution Process

### Step 1: Verify Storage Presentation

Validated:
esxcli storage core device list -d naa.600c0ff000fdbdbde267b46701000000

Confirmed expanded LUN size visible.

### Step 2: Force VMFS Metadata Refresh

Executed:
vmkfstools -V

This forced a VMFS volume rescan and metadata refresh.

### Step 3: Validate Datastore Size

Executed:
esxcli storage filesystem list

Observed:
- Datastore size updated successfully
- Capacity matched ESXi5 and ESXi6
- Expansion visible across all hosts

## Final Outcome

- VMFS metadata refreshed successfully
- Datastore capacity updated correctly
- All ESXi hosts showed identical datastore size
- No storage outage occurred
- Shared datastore expansion completed successfully

## Recommended Procedure After Future LUN Expansions

### Rescan Storage Adapters
esxcli storage core adapter rescan --all

### Refresh VMFS Volumes

vmkfstools -V

### Verify Datastore Capacity

esxcli storage filesystem list

### Verify VMFS Extents
esxcli storage vmfs extent list

## Key Learning

### Major Insights

- LUN expansion visibility does not guarantee VMFS metadata refresh.
- ESXi hosts may cache outdated VMFS information.
- If LUN size matches across hosts but datastore size differs, VMFS metadata refresh is required.
- `vmkfstools -V` is an effective method to force VMFS volume refresh without disruption.
- This issue is typically host-side metadata caching rather than a storage-array problem.

## Severity

**Production Storage Capacity Visibility Issue**

## Skills Demonstrated

- VMware ESXi administration
- VMFS troubleshooting
- Dell ME5 storage administration
- iSCSI troubleshooting
- Datastore expansion validation
- Storage presentation analysis
- Root cause analysis
- Production infrastructure support

## Business Impact

- Restored accurate datastore visibility
- Confirmed successful storage expansion
- Prevented unnecessary storage troubleshooting
- Improved shared datastore management
