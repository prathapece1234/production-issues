# Kubernetes SSO Integration with Microsoft Entra ID (On-Premises)

## Overview

Participated in the evaluation and planning of Single Sign-On (SSO) integration for an on-premises Kubernetes cluster using **Microsoft Entra ID** 
as the Identity Provider (IdP). The objective was to centralize authentication, eliminate local user management, and enable secure access to 
Kubernetes using enterprise identities.

The implementation leveraged **OpenID Connect (OIDC)** for authentication and **Kubernetes RBAC** for authorization, allowing users to authenticate 
through Microsoft Entra ID while controlling access based on assigned groups.

---

# Environment

| Component         | Details                    |
| ----------------- | -------------------------- |
| Platform          | On-Premises Kubernetes     |
| Identity Provider | Microsoft Entra ID         |
| Authentication    | OpenID Connect (OIDC)      |
| Authorization     | Kubernetes RBAC            |
| Existing Identity | Microsoft 365 / Office 365 |

---

# Objective

* Integrate Kubernetes authentication with Microsoft Entra ID.
* Enable Single Sign-On (SSO) for cluster access.
* Eliminate local Kubernetes user management.
* Implement centralized identity and access management.
* Use Microsoft Entra groups for Kubernetes RBAC authorization.

---

# Requirements Collection

Worked with stakeholders to gather identity and authentication requirements before implementation.

Collected information regarding:

* Current Identity Provider
* OIDC support
* Microsoft Entra tenant information
* Allowed tenants
* Group configuration
* User authentication flow
* RBAC requirements
* Administrative access
* Namespace-level permissions

---

# Solution Design

The proposed authentication workflow allows Kubernetes to delegate user authentication to Microsoft Entra ID using OpenID Connect.

```
User
   │
   ▼
Microsoft Entra ID
   │
OIDC Authentication
   │
   ▼
Kubernetes API Server
   │
Validate ID Token
   │
Extract User & Group Claims
   │
   ▼
Kubernetes RBAC
   │
Authorize Access
```

---

# Implementation Activities

* Evaluated Microsoft Entra ID as the Identity Provider.
* Reviewed OIDC compatibility with Kubernetes.
* Collected tenant and group configuration requirements.
* Planned RBAC group mappings.
* Reviewed authentication and authorization workflow.
* Documented implementation approach.
* Coordinated with stakeholders for identity integration.

---

# Kubernetes API Server Configuration (OIDC)

Example API Server configuration:

```bash
--oidc-issuer-url=https://login.microsoftonline.com/<TENANT-ID>/v2.0
--oidc-client-id=<APPLICATION-ID>
--oidc-username-claim=email
--oidc-groups-claim=groups
```

---

# Create Cluster Role

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-readonly
rules:
- apiGroups: [""]
  resources:
    - pods
    - services
    - namespaces
  verbs:
    - get
    - list
    - watch
```

Apply:

```bash
kubectl apply -f clusterrole.yaml
```

---

# Create Cluster Role Binding

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: entra-readonly-users
subjects:
- kind: Group
  name: Kubernetes-ReadOnly
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-readonly
  apiGroup: rbac.authorization.k8s.io
```

Apply:

```bash
kubectl apply -f clusterrolebinding.yaml
```

---

# Useful Validation Commands

Check cluster information:

```bash
kubectl cluster-info
```

View cluster nodes:

```bash
kubectl get nodes
```

View namespaces:

```bash
kubectl get namespaces
```

List ClusterRoles:

```bash
kubectl get clusterroles
```

List ClusterRoleBindings:

```bash
kubectl get clusterrolebindings
```

Describe a ClusterRoleBinding:

```bash
kubectl describe clusterrolebinding entra-readonly-users
```

View API Server OIDC configuration (control plane node):

```bash
ps -ef | grep kube-apiserver
```

or

```bash
cat /etc/kubernetes/manifests/kube-apiserver.yaml
```

---

# Validation

Validated the following after configuration planning:

* Kubernetes API server supports OIDC.
* Microsoft Entra ID can act as the Identity Provider.
* User authentication is performed through Microsoft Entra ID.
* User and group claims are available in OIDC tokens.
* RBAC permissions can be mapped using Microsoft Entra groups.
* Cluster access is controlled through Kubernetes RBAC.

---

# Outcome

* Successfully completed the initial assessment for Kubernetes SSO integration.
* Identified Microsoft Entra ID as the enterprise Identity Provider.
* Designed an authentication architecture based on OpenID Connect.
* Defined RBAC group mapping requirements.
* Established a scalable and secure authentication model for future implementation.

---

# Technologies Used

* Kubernetes
* Microsoft Entra ID
* Microsoft 365
* OpenID Connect (OIDC)
* Kubernetes RBAC
* Identity & Access Management (IAM)

---

# Key Learnings

* OpenID Connect provides a secure and standardized authentication mechanism for Kubernetes.
* Microsoft Entra ID simplifies centralized identity management for enterprise environments.
* Group-based RBAC improves security and reduces administrative overhead.
* Proper planning of tenants, claims, and RBAC mappings is essential for a successful SSO implementation.

---
