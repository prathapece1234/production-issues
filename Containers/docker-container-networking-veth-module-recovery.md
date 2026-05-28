# Docker Container Networking Failure Due to Missing VETH Kernel Module

## Incident Summary

Docker images were available on the server, but containers could not be started due to a networking initialization failure. 
Docker was unable to create the required virtual Ethernet (veth) interfaces used for container networking.

## Environment

- OS: Ubuntu Linux
- Container Platform: Docker
- Network Driver: Docker Bridge
- Kernel: 6.8.0-117-generic

## Symptoms Observed

Containers failed to start with the following error:

failed to set up container networking:
failed to add the host veth pair interfaces:
operation not supported

Example:
docker run -it authgatewaytest:0.1 sh

Docker images were present but no containers could be launched.

## Investigation

### Initial Validation

Verified Docker status:

docker info
docker images

Confirmed:

* Docker daemon running
* Images available
* Container startup failing during network initialization

### Kernel Module Validation

Checked for VETH kernel support:
grep CONFIG_VETH /boot/config-$(uname -r)

Verified module existence:

find /lib/modules/$(uname -r) -name "veth*"

Initially identified missing or unloaded VETH networking support.

## Root Cause

Docker bridge networking requires the Linux VETH (Virtual Ethernet Pair) kernel module.

The required VETH module was not loaded, preventing Docker from creating container network interfaces.

As a result:

* Docker bridge networking failed
* Container startup failed
* Host veth pair creation failed
* Container runtime became unusable

## Resolution Process

### Step 1: Install Required Kernel Modules

Updated repositories:
sudo apt update

Installed kernel extra modules:

sudo apt install linux-modules-extra-$(uname -r)

Reinstalled required kernel packages:

sudo apt install --reinstall linux-modules-$(uname -r)
sudo apt install --reinstall linux-modules-extra-$(uname -r)

### Step 2: Verify VETH Module

Validated module presence:

find /lib/modules/$(uname -r) -name "veth*"

Output:
/lib/modules/6.8.0-117-generic/kernel/drivers/net/veth.ko.zst


### Step 3: Load VETH Module

Loaded module manually:

sudo modprobe veth

Validated:
lsmod | grep veth

Confirmed VETH module active.

### Step 4: Restart Docker

Restarted Docker service:

sudo systemctl restart docker

### Step 5: Validation

Executed test container:

sudo docker run hello-world

Confirmed:

* Container networking initialized successfully
* Docker bridge operational
* Containers started normally


## Final Outcome

* Docker networking restored
* VETH kernel module loaded successfully
* Docker bridge functionality recovered
* Containers started successfully
* Application deployment unblocked


## Preventive Measures

* Validate required kernel modules after OS upgrades
* Include VETH verification in Docker health checks
* Maintain baseline Docker host configuration
* Monitor container runtime logs for networking failures
* Verify kernel package completeness after updates


## Key Learning

### Major Insights

* Docker bridge networking depends on the Linux VETH kernel module.
* Missing kernel modules can break container networking even when Docker itself is healthy.
* Docker images and daemon availability do not guarantee container startup capability.
* Verifying kernel networking support should be part of Docker troubleshooting.


## Severity

**Production Container Platform Issue**

## Skills Demonstrated

* Docker troubleshooting
* Linux kernel module management
* Container networking diagnostics
* Ubuntu administration
* Docker bridge networking
* Root cause analysis
* Production incident handling
* Infrastructure troubleshooting

## Business Impact

* Restored container deployment capability
* Recovered Docker networking functionality
* Reduced application deployment delays
* Improved container platform reliability

```
```
