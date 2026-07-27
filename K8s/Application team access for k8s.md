Application Team Access Management

## Overview

Implemented secure namespace-based access management for application teams by integrating **Microsoft Entra ID (OIDC)** with Kubernetes RBAC.

Instead of creating individual Kubernetes users, application engineers authenticate using their corporate Microsoft Entra ID credentials. 
User authorization is controlled through Microsoft Entra security groups mapped to Kubernetes Roles and RoleBindings.

The application team manages only their assigned application namespace using **K9s** and **kubectl**, without requiring cluster administrator 
privileges.

---

# Authentication Workflow

```text
Application Team Member
        │
        ▼
Login using Microsoft Entra ID
        │
        ▼
OIDC Authentication
        │
        ▼
Receive JWT Token
        │
        ▼
Kubernetes API Server
        │
Validate User & Group Claims
        │
        ▼
Kubernetes RBAC
        │
Check Namespace Permissions
        │
        ▼
Access Granted
        │
        ▼
K9s / kubectl
```

---

# Access Model

```text
Microsoft Entra ID

K8S-Application-Team
│
├── User1
├── User2
├── User3
├── User4
└── User5
        │
        ▼
OIDC Authentication
        │
        ▼
Kubernetes API Server
        │
        ▼
RoleBinding
        │
        ▼
Namespace : payment-prod
```

---

# Responsibilities

* Configured namespace-level RBAC.
* Mapped Microsoft Entra groups to Kubernetes Roles.
* Restricted users to application namespaces only.
* Validated authentication using OIDC.
* Tested access through K9s and kubectl.
* Verified least-privilege access.

---

# Allowed Operations

Application team members were able to:

* View Pods
* View Deployments
* Restart Applications
* Scale Applications
* Delete Failed Pods
* View Logs
* Execute into Pods
* Update ConfigMaps
* Check Rollout Status
* Rollback Deployments
* Monitor Application Health

---
### RBAC for application team

The Role allows the application team to create, update, patch, and delete resources in their namespace.

apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: payment-prod
  name: application-admin

rules:
- apiGroups: ["", "apps", "networking.k8s.io"]
  resources:
    - deployments
    - statefulsets
    - daemonsets
    - services
    - ingresses
    - configmaps
    - pods
    - pods/log
    - pods/exec
  verbs:
    - get
    - list
    - watch
    - create
    - update
    - patch
    - delete

---
## Login (OIDC)

```bash
kubectl get pods
```

If the token is expired, users are redirected to Microsoft Entra ID to authenticate again.

---

## Open K9s

```bash
k9s
```

---

## View Namespace

```bash
kubectl config view --minify
```

---

## List Pods

```bash
kubectl get pods -n payment-prod
```

---

## View Deployments

```bash
kubectl get deployments -n payment-prod
```

---

## View Services

```bash
kubectl get svc -n payment-prod
```

---

## View Ingress

```bash
kubectl get ingress -n payment-prod
```

---

## View Logs

```bash
kubectl logs payment-api-6d7f7b9d8f-x8z9m -n payment-prod
```

Follow logs

```bash
kubectl logs -f payment-api-6d7f7b9d8f-x8z9m -n payment-prod
```

---

## Execute Inside Pod

```bash
kubectl exec -it payment-api-6d7f7b9d8f-x8z9m -n payment-prod -- /bin/bash
```

or

```bash
kubectl exec -it payment-api-6d7f7b9d8f-x8z9m -n payment-prod -- /bin/sh
```

---

## Restart Deployment

```bash
kubectl rollout restart deployment payment-api -n payment-prod
```

---

## Check Rollout Status

```bash
kubectl rollout status deployment payment-api -n payment-prod
```

---

## Rollback Deployment

```bash
kubectl rollout undo deployment payment-api -n payment-prod
```

---

## Scale Deployment

```bash
kubectl scale deployment payment-api --replicas=5 -n payment-prod
```

---

## Edit Deployment

```bash
kubectl edit deployment payment-api -n payment-prod
```

---

## Describe Pod

```bash
kubectl describe pod payment-api-6d7f7b9d8f-x8z9m -n payment-prod
```

---

## Delete Failed Pod

```bash
kubectl delete pod payment-api-6d7f7b9d8f-x8z9m -n payment-prod
```

The Deployment automatically recreates the Pod.

---

## View ConfigMaps

```bash
kubectl get configmap -n payment-prod
```

---

## Edit ConfigMap

```bash
kubectl edit configmap payment-config -n payment-prod
```

---

## Check Events

```bash
kubectl get events -n payment-prod --sort-by=.metadata.creationTimestamp
```

---

# Validation Commands

Verify current authenticated user context:

```bash
kubectl config current-context
```

Check namespace access:

```bash
kubectl auth can-i get pods -n payment-prod
```

```bash
kubectl auth can-i create deployment -n payment-prod
```

```bash
kubectl auth can-i delete pods -n payment-prod
```

Verify restricted access:

```bash
kubectl auth can-i get nodes
```

Expected Output:

```text
no
```

Verify access to another namespace:

```bash
kubectl auth can-i get pods -n kube-system
```

Expected Output:

```text
no
```

---

# Security Controls

* Microsoft Entra ID used as the centralized Identity Provider.
* Authentication performed using OpenID Connect (OIDC).
* Namespace-based RBAC enforced least-privilege access.
* No local Kubernetes users were created.
* No cluster-admin privileges assigned to application teams.
* Access automatically granted or revoked based on Microsoft Entra group membership.

---

# Outcome

* Successfully implemented secure namespace-level access for application teams.
* Enabled developers to manage application workloads independently using **K9s** and **kubectl**.
* Simplified user lifecycle management through Microsoft Entra ID groups.
* Improved security by enforcing Kubernetes RBAC and least-privilege access.
* Eliminated the need for manual Kubernetes user administration while maintaining centralized authentication and authorization.
