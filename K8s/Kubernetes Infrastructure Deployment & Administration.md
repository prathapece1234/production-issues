# On-Premises Kubernetes Infrastructure Deployment & Administration

## Overview

Designed, deployed, and managed a highly available **on-premises Kubernetes cluster** consisting of **3 Control Plane (Master) nodes** and 
**6 Worker nodes**. Responsible for the complete Kubernetes infrastructure lifecycle, including cluster deployment, node provisioning, 
virtualization management, operating system administration, capacity planning, upgrades, troubleshooting, and production support.

Managed the underlying virtual machines, Kubernetes components, Linux operating systems, authentication, RBAC, monitoring, and application platform 
to ensure a stable and highly available production environment.

---

# Cluster Architecture

| Node Type               | Purpose                                                    |
| ----------------------- | ---------------------------------------------------------- |
| Control Plane Nodes (3) | Kubernetes API Server, Scheduler, Controller Manager, etcd |
| Worker Nodes (3)        | Production Application Workloads                           |
| Worker Nodes (3)        | Monitoring, Logging & Platform Tools, Softwares            |

---

# Kubernetes Cluster Deployment

## Overview

Successfully deployed the Kubernetes cluster from scratch using **kubeadm**, including Control Plane initialization, Worker node onboarding, 
container runtime installation, networking configuration, and cluster validation.

---

## Installation Activities

### Operating System Preparation

Configured all Control Plane and Worker nodes by:

* Installing the supported Linux operating system.
* Updating system packages.
* Configuring hostname and DNS resolution.
* Updating `/etc/hosts`.
* Disabling swap.
* Loading required kernel modules.
* Configuring Kubernetes sysctl parameters.
* Enabling IP forwarding.
* Installing required dependencies.

---

### Container Runtime Installation

Installed and configured **containerd** as the Kubernetes container runtime.

```bash
containerd config default > /etc/containerd/config.toml
systemctl enable --now containerd
systemctl restart containerd
```

---

### Kubernetes Component Installation

Installed Kubernetes components on all Control Plane and Worker nodes.

```bash
kubeadm
kubelet
kubectl
```

Enabled kubelet service.

```bash
systemctl enable kubelet
systemctl start kubelet
```

---

### Control Plane Initialization

Initialized the primary Control Plane node.

```bash
kubeadm init \
--control-plane-endpoint <VIP> \
--pod-network-cidr=<POD_NETWORK_CIDR>
```

Configured kubectl access.

```bash
mkdir -p $HOME/.kube

cp /etc/kubernetes/admin.conf $HOME/.kube/config

chown $(id -u):$(id -g) $HOME/.kube/config
```

---

### Cluster Networking

Installed the Kubernetes CNI plugin for Pod networking.

```bash
kubectl apply -f calico.yaml
```

---

### Join Additional Control Plane Nodes

```bash
kubeadm join <CONTROL_PLANE_ENDPOINT>:6443 \
--token <TOKEN> \
--discovery-token-ca-cert-hash sha256:<HASH> \
--control-plane
```

---

### Join Worker Nodes

```bash
kubeadm join <CONTROL_PLANE_ENDPOINT>:6443 \
--token <TOKEN> \
--discovery-token-ca-cert-hash sha256:<HASH>
```

---

### Cluster Validation

Verified cluster health after deployment.

```bash
kubectl get nodes
```

```bash
kubectl get pods -A
```

```bash
kubectl cluster-info
```

```bash
kubectl get namespaces
```

---

# Kubernetes Administration

Managed day-to-day Kubernetes operations, including:

* Control Plane and Worker node administration.
* Node lifecycle management.
* Cluster health monitoring.
* Kubernetes upgrades and maintenance.
* Namespace administration.
* RBAC configuration.
* Microsoft Entra ID (OIDC) authentication integration.
* Application deployment support.
* Pod scheduling and troubleshooting.
* Deployment management.
* Service and Ingress troubleshooting.
* ConfigMap and Secret management.
* Storage troubleshooting.
* Resource utilization monitoring.
* Production incident troubleshooting.
* Root Cause Analysis (RCA).

---

# Virtual Machine Administration

Managed the virtual infrastructure hosting the Kubernetes cluster.

Responsibilities included:

* Provisioning new virtual machines.
* Deploying Control Plane and Worker nodes.
* CPU allocation and expansion.
* Memory (RAM) upgrades.
* Virtual disk expansion.
* Linux filesystem expansion after disk extension.
* Virtual machine restart and recovery during hung or unresponsive states.
* Snapshot creation before maintenance activities.
* Resource optimization and capacity planning.
* Infrastructure health verification.

---

# Linux Administration

Performed operating system administration across all Kubernetes nodes.

* User and group management.
* Package installation and updates.
* Service management.
* Filesystem administration.
* LVM and disk management.
* SSH configuration.
* System performance tuning.
* Log analysis.
* Security hardening.
* Production issue troubleshooting.

---

# Cluster Operations

Performed regular operational activities, including:

* Monitoring cluster resource utilization.
* CPU, Memory, and Storage capacity planning.
* Node maintenance using cordon, drain, and uncordon.
* Cluster validation after maintenance.
* Backup coordination.
* Infrastructure documentation.
* Incident response and troubleshooting.
* Change implementation and validation.

---

# Frequently Used Commands

## Cluster Health

```bash
kubectl get nodes

kubectl get pods -A

kubectl cluster-info

kubectl top nodes

kubectl top pods -A
```

---

## Node Management

```bash
kubectl describe node <node-name>

kubectl cordon <node-name>

kubectl drain <node-name> --ignore-daemonsets

kubectl uncordon <node-name>
```

---

## Resource Validation

```bash
lscpu

free -h

nproc

hostnamectl

df -h

lsblk
```

---

## Storage Management

```bash
pvdisplay

vgdisplay

lvdisplay

growpart

xfs_growfs

resize2fs
```

---

## Kubernetes Services

```bash
systemctl status kubelet

systemctl restart kubelet
```

---

## Logs

```bash
journalctl -u kubelet

kubectl logs <pod-name>
```

---

## Networking

```bash
kubectl get svc -A

kubectl get ingress -A
```

---

# Technologies Used

* Kubernetes
* kubeadm
* kubelet
* kubectl
* containerd
* Linux (RHEL/Ubuntu)
* Calico (or the deployed CNI)
* Microsoft Entra ID (OIDC)
* Kubernetes RBAC
* K9s
* Helm
* VMware / On-Premises Virtualization

---

# Key Achievements

* Designed and deployed a highly available on-premises Kubernetes cluster from scratch.
* Installed and configured Control Plane and Worker nodes using kubeadm.
* Managed the complete Kubernetes infrastructure lifecycle.
* Provisioned and maintained virtual machines for Kubernetes workloads.
* Performed CPU, memory, and storage upgrades without impacting production workloads.
* Expanded Linux filesystems following virtual disk extensions.
* Implemented Microsoft Entra ID (OIDC) authentication and namespace-based RBAC.
* Supported application teams with secure namespace-level access using K9s and kubectl.
* Managed cluster maintenance, upgrades, troubleshooting, and production incidents.
* Performed capacity planning, infrastructure optimization, and operational documentation.
* Collaborated with application, infrastructure, virtualization, and network teams to ensure a stable, secure, and highly available Kubernetes 
  platform.
