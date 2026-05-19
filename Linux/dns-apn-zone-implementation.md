# DNS APN Zone Implementation

## Implementation Summary
Implemented new APN DNS zone configuration on production DNS servers based on operations team request for new network service integration.

## Implemented Zones
Created and configured:
- apn.epc.mnc028.mcc730.3gppnetwork.org
- internet.mnc028.mcc730.gprs

---

## Configuration Activities

### Zone File Creation
Created new DNS zone files for APN resolution support in /etc/named.conf

### Record Configuration 
Added required in /var/named files
- NAPTR records
- A records

### Zone Validation
Validated DNS zone configurations using:

named-checkzone

### Permission and Ownership Configuration

Configured proper permissions and ownership for BIND access:

chmod 755 apn.epc.mnc028.mcc730.3gppnetwork.org
chmod 755 internet.mnc028.mcc730.gprs

chown root:named apn.epc.mnc028.mcc730.3gppnetwork.org
chown root:named internet.mnc028.mcc730.gprs

### BIND Reload

Reloaded DNS service successfully: rndc reload

## Validation

Validated DNS resolution successfully using:

dig @127.0.0.1 internet.apn.epc.mnc028.mcc730.3gppnetwork.org NAPTR

### Validation Result

* NAPTR lookup successful
* DNS zones resolving correctly
* BIND reload completed successfully
* APN DNS implementation operational

---

## Final Outcome

* New APN DNS zones implemented successfully
* DNS resolution functioning correctly
* Production configuration completed
* Network service integration enabled

---

## Skills Demonstrated

* Linux administration
* BIND DNS configuration
* APN DNS implementation
* NAPTR record configuration
* DNS validation
* Production infrastructure implementation
* Network service support

