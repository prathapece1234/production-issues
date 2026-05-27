# Docker and Containerd Recovery After System Library Corruption

## Incident Summary

Following a filesystem corruption incident caused by accidental deletion of critical libraries within a chroot environment, 
Docker services became unavailable on the Ubuntu server. Although Docker binaries were present, the Docker daemon and containerd 
services could not start.

## Environment

- OS: Ubuntu Linux
- Container Platform: Docker
- Runtime: containerd

## Symptoms Observed

- Docker commands failed
- Containers unavailable
- Docker daemon not running
- Docker socket missing
- containerd service unavailable

Observed errors:
docker ps
failed to connect to the docker API at unix:///var/run/docker.sock

systemctl status docker.service
Unit docker.service could not be found.

systemctl status containerd.service
Unit containerd.service could not be found.

## Investigation

### Initial Validation

Verified Docker binary availability:

which docker
docker --version

Results:
* Docker binary available under `/usr/bin/docker`
* Docker package appeared installed

### Service Validation

Checked:

systemctl status docker.service
systemctl status containerd.service

Observed:

* Docker service definition missing
* Containerd service definition missing
* Docker socket unavailable

### Root Cause Analysis

Further investigation revealed that critical runtime libraries had been removed during a previous filesystem corruption incident.

Affected library locations included:

/lib
/usr/lib
/usr/lib64


As a result:

* Docker runtime dependencies were incomplete
* containerd runtime was broken
* systemd service files were missing or unusable
* Docker daemon could not initialize

## Resolution Process

### Step 1: Operating System Recovery

* Recovered server access
* Restored required system libraries
* Verified operating system integrity

### Step 2: Runtime Verification

Validated:

* Docker binary
* Runtime dependencies
* Library availability
* Service registration

### Step 3: Docker and Containerd Reinstallation

Reinstalled:

docker-ce
docker-ce-cli
containerd

Restored:

* docker.service
* docker.socket
* containerd.service

### Step 4: Service Recovery

Started and enabled services:

systemctl enable --now containerd
systemctl enable --now docker

### Step 5: Validation

Verified:

docker ps
docker images
systemctl status docker
systemctl status containerd

Confirmed:

* Docker daemon operational
* Containerd operational
* Docker socket created successfully
* Container management restored

## Final Outcome

* Docker Engine restored successfully
* Containerd runtime restored
* Service files recovered
* Container platform operational
* Production workloads available again

## Preventive Measures

* Restrict privileged filesystem access
* Implement backup procedures for critical systems
* Protect system library directories
* Validate changes before executing destructive commands
* Maintain Docker runtime recovery documentation

## Key Learning

### Major Insights

* Docker binaries may remain installed while runtime services are broken.
* Docker depends heavily on containerd and underlying system libraries.
* Missing runtime libraries can remove service functionality even when packages appear installed.
* Reinstallation is often the fastest recovery method once library corruption occurs.

## Severity

**Production Container Platform Incident**

## Skills Demonstrated

* Docker administration
* containerd troubleshooting
* Ubuntu administration
* Linux runtime recovery
* Service restoration
* Production incident management
* Root cause analysis
* Container platform recovery

## Business Impact

* Restored production container platform
* Recovered Docker management capabilities
* Prevented full server rebuild
* Reduced production downtime
