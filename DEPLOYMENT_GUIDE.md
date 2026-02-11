# Deployment & Verification Guide

This guide details how to validate, plan, and deploy the expanded infrastructure including EKS, RDS, ECR, and ArgoCD.

## Prerequisites

- AWS CLI configured with necessary permissions.
- Terraform v1.5+ installed.
- `kubectl` installed.

## 1. Validation & Planning

First, initialize the new modules and validated the configuration:

```powershell
cd d:\terraform-pipelines\terraform
terraform init
terraform validate
```

If validation passes, create a deployment plan:

```powershell
terraform plan -out=tfplan
```

Review the plan to ensure:
- Region is `us-east-1`.
- `module.rds.aws_db_instance.backend` is created.
- `module.ecr.aws_ecr_repository` resources are created.
- `module.argocd.helm_release.argocd` is created.

## 2. Deployment

Apply the infrastructure changes:

```powershell
terraform apply tfplan
```

## 3. Post-Deployment Configuration

### Update Kubeconfig

Configure `kubectl` to interact with your new EKS cluster:

```powershell
aws eks update-kubeconfig --region us-east-1 --name devops-eks
```

### Accessing ArgoCD

Retrieve the initial admin password:

```powershell
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

Port-forward to access the UI (if LoadBalancer is not yet provisioned or DNS is not set):

```powershell
kubectl port-forward ns/argocd svc/argocd-server 8080:443
```

Access at `https://localhost:8080`. Username: `admin`.

### Database Connection

The RDS instance is in private subnets. To connect for testing, use a pod within the cluster:

```powershell
kubectl run -it --rm --image=postgres:16-alpine db-test --context=arn:aws:eks:us-east-1:ACCOUNT_ID:cluster/devops-eks -- \
  psql -h <RDS_ENDPOINT> -U appuser -d backend
```

## 4. Ingress Configuration

An example Ingress file is provided at `d:\terraform-pipelines\terraform\ingress-example.yaml`.

Since there is no Route53 DNS zone, you accepted using HTTP or a self-signed cert. The ALB Ingress Controller will provision an Application Load Balancer. You can access the service using the ALB's DNS name (retrievable via `kubectl get ingress`).
