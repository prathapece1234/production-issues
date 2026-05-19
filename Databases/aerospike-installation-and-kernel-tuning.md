## Implementation Summary
Installed and configured Aerospike Enterprise Server with required Linux kernel tuning parameters for optimal database performance and 
stability.

## Prechecks and Kernel Parameter Configuration

Configured the following kernel parameters:

net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.netdev_max_backlog = 250000
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_tw_reuse = 1
fs.file-max = 1000000
vm.swappiness = 0
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
vm.min_free_kbytes = 1310720


## Transparent Huge Pages (THP)

Configured THP as: never

## Zone Reclaim Mode

Disabled zone reclaim mode:  /proc/sys/vm/zone_reclaim_mode = 0


## Persistent Storage Recommended Parameters

For persistent storage deployments, the following parameters are recommended:

/proc/sys/vm/dirty_bytes = 16777216
/proc/sys/vm/dirty_background_bytes = 1
/proc/sys/vm/dirty_expire_centisecs = 1
/proc/sys/vm/dirty_writeback_centisecs = 10

Note:
Current setup uses storage engine type memory, so persistent storage tuning was not enabled.


## Aerospike Installation Steps

### Download Aerospike Package

Downloaded Aerospike Enterprise package from:

https://download.aerospike.com/artifacts/aerospike-server-enterprise

### Extract Package

tar -xzf file-name

### Installation

cd /opt/aerospike*
./asinstall

## Configuration

Moved to Aerospike configuration directory:
cd /etc/aerospike

Edit the below file
aerospike.conf

Configured required Aerospike settings and saved configuration.

## Service Startup

Enabled and started Aerospike service:

systemctl enable --now aerospike

---

## Validation

Validated cluster information using:

asadm -e "info"

---

## Filesystem Information

Current setup uses:
ext4

### Recommendation

* ext4 is sufficient for development and testing environments
* For production environments, XFS filesystem is recommended
* XFS implementation is mainly required when using storage engine type `device`


## Final Outcome

* Aerospike Enterprise installed successfully
* Kernel tuning parameters configured
* Aerospike service operational
* Cluster validation completed
* Database environment ready for development/testing usage

## Skills Demonstrated

* Linux system administration
* Kernel parameter tuning
* Aerospike installation
* Database infrastructure setup
* Performance optimization
* Service management
* Production precheck implementation
* Storage and filesystem planning

