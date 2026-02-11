# Terraform CI/CD Pipeline with GitHub Actions

A production-ready, automated infrastructure deployment pipeline using Terraform and GitHub Actions with comprehensive validation, security scanning, and manual approval gates.

## 🎯 Overview

This project implements a complete CI/CD pipeline for Terraform infrastructure with four distinct workflows:

1. **Development Validation** - Validates code quality on dev branch
2. **Pull Request Review** - Security scanning and plan generation for PRs
3. **Production Apply** - Deploys infrastructure with manual approval
4. **Manual Destroy** - Safely tears down infrastructure when needed

## 🏗️ Infrastructure

The included Terraform code deploys a production-ready AWS infrastructure:

- **VPC** with public and private subnets across multiple AZs
- **EKS Cluster** with managed node groups
- **RDS PostgreSQL** database in private subnets
- **ECR Repositories** for container images (frontend, backend, database)
- **ArgoCD** for GitOps-based deployments
- **NAT Gateway** for private subnet internet access
- **NGINX Ingress Controller** for traffic management

## 🚀 Quick Start

**Complete setup guide**: See [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) for detailed step-by-step instructions.

### Prerequisites

- AWS Account
- GitHub Account  
- AWS IAM credentials
- S3 bucket for Terraform state
- DynamoDB table for state locking

### Quick Setup

1. **Clone and initialize**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/terraform-pipelines.git
   cd terraform-pipelines
   ```

2. **Configure GitHub Secrets**:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_REGION`
   - `TF_STATE_BUCKET`
   - `TF_STATE_DYNAMODB_TABLE`

3. **Create GitHub Environment**:
   - Name: `production`
   - Add required reviewers
   - Restrict to `main` branch

4. **Deploy**:
   ```bash
   git checkout dev
   git push origin dev                    # Triggers validation
   # Create PR from dev to main           # Triggers security scan
   # Merge PR                              # Triggers production deploy (with approval)
   ```

## 📊 Pipeline Architecture

```mermaid
graph LR
    A[Push to dev] --> B[Dev Validation]
    B --> C[Create PR]
    C --> D[PR Review + Checkov]
    D --> E[Manual Review]
    E --> F[Merge to main]
    F --> G[Manual Approval]
    G --> H[Production Apply]
    I[Manual Trigger] --> J[Destroy]
```

## 🔄 Workflow Details

### 1. Development Validation Pipeline

**Trigger**: Push to `dev` branch

**Steps**:
- ✅ Terraform format check (`terraform fmt -check`)
- ✅ Initialize providers and backend
- ✅ Validate configuration syntax
- ✅ Generate plan (non-destructive)

**Purpose**: Catch errors early before creating a PR

---

### 2. Pull Request Review Pipeline

**Trigger**: Pull request to `main` branch

**Steps**:
- ✅ Validate Terraform configuration
- ✅ **Checkov security scan** for compliance issues
- ✅ Generate Terraform plan with production config
- ✅ Upload plan artifact (30-day retention)
- ✅ Post plan summary as PR comment

**Purpose**: Security review and change visibility before approval

---

### 3. Production Apply Pipeline

**Trigger**: Merge/push to `main` branch

**Steps**:
- ⏸️ **Manual approval required** (GitHub Environment)
- ✅ Initialize with production backend
- ✅ Generate and apply Terraform plan
- ✅ Output infrastructure details (IPs, IDs, URLs)

**Purpose**: Safely deploy approved infrastructure changes

**Environment**: `production` (requires approval)

---

### 4. Manual Destroy Pipeline

**Trigger**: Manual workflow dispatch

**Steps**:
- ✋ Confirmation input required (`DESTROY`)
- ⏸️ Manual approval required
- ✅ Generate destroy plan
- ✅ Destroy all managed resources

**Purpose**: Clean up infrastructure when no longer needed

**Safety**: Double confirmation (input + approval)

## 📁 Project Structure

```
terraform-pipelines/
├── .github/
│   ├── scripts/
│   │   ├── convert_checkov_to_html.py          # Checkov HTML converter
│   │   ├── generate-dev-validation-summary.sh  # Dev validation summary
│   │   ├── generate-pr-summary.sh              # PR review summary
│   │   └── generate-production-summary.sh      # Production deployment summary
│   └── workflows/
│       ├── dev-validation.yml        # Dev branch validation
│       ├── pr-review.yml             # PR security scan & plan
│       ├── production-apply.yml      # Production deployment
│       ├── manual-destroy.yml        # Infrastructure teardown
│       └── force-unlock.yml          # State lock management
├── terraform/
│   ├── vpc/                          # VPC, subnets, NAT gateway
│   ├── eks/                          # EKS cluster and node groups
│   ├── rds/                          # PostgreSQL database
│   ├── ecr/                          # Container registries
│   ├── argocd/                       # ArgoCD deployment
│   ├── ingress/                      # NGINX ingress controller
│   ├── main.tf                       # Module orchestration
│   ├── variables.tf                  # Input variables
│   ├── outputs.tf                    # Resource outputs
│   ├── provider.tf                   # AWS, Kubernetes, Helm providers
│   ├── data.tf                       # Data sources
│   └── terraform.tfvars              # Variable values
├── DEPLOYMENT_GUIDE.md               # Step-by-step setup guide
└── README.md                         # This file
```

## 🔒 Security Features

- ✅ **Checkov scanning** for security misconfigurations
- ✅ **Manual approval gates** for production deployments
- ✅ **Encrypted S3 backend** for state storage
- ✅ **State locking** with DynamoDB
- ✅ **IMDSv2 enforcement** on EC2 instances
- ✅ **Encrypted EBS volumes** by default
- ✅ **Environment-based access control**

## 🛠️ Configuration

### Required GitHub Secrets

| Secret | Description | Example |
|--------|-------------|---------|
| `AWS_ACCESS_KEY_ID` | AWS access key | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| `AWS_REGION` | AWS region | `us-east-1` |
| `TF_STATE_BUCKET` | S3 bucket name | `terraform-state-20260207-company` |
| `TF_STATE_DYNAMODB_TABLE` | DynamoDB table | `terraform-state-lock` |

### Terraform Variables

Edit `terraform/terraform.tfvars`:

```hcl
aws_region         = "us-east-1"
cluster_name       = "devops-eks"
vpc_cidr           = "10.0.0.0/16"
public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets    = ["10.0.10.0/24", "10.0.20.0/24"]
allowed_public_ip  = "0.0.0.0/0"  # Restrict to your IP for production
```

## 📈 Monitoring

### View Deployment Status

- **GitHub Actions**: Check workflow runs under the "Actions" tab
- **AWS Console**: Verify resources in VPC and EC2 dashboards
- **Terraform Outputs**: View in workflow summary or run `terraform output`

### Cost Monitoring

**Expected Monthly Cost**:
- EKS Cluster: ~$73/month (control plane)
- EC2 Nodes (t3.medium x2): ~$60/month
- RDS PostgreSQL (db.t3.micro): ~$15/month
- NAT Gateway: ~$32/month
- S3, DynamoDB: < $1/month
- **Total**: ~$180/month

**Set up billing alerts**:
1. AWS Console → CloudWatch → Billing
2. Create alarm for spend > $200/month

## 🧪 Testing

### Access the EKS Cluster

After successful deployment:

1. Configure kubectl:
   ```bash
   aws eks update-kubeconfig --region us-east-1 --name devops-eks
   ```

2. Verify cluster access:
   ```bash
   kubectl get nodes
   kubectl get pods -A
   ```

### Access ArgoCD

1. Get the initial admin password:
   ```bash
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
   ```

2. Port-forward to access the UI:
   ```bash
   kubectl port-forward ns/argocd svc/argocd-server 8080:443
   ```

3. Open browser: `https://localhost:8080` (username: `admin`)

## 🔧 Customization

### Add More Resources

Create new modules in `terraform/` for:
- ElastiCache for caching
- CloudFront distributions
- S3 buckets for static assets
- Lambda functions
- API Gateway

### Multi-Environment Support

Create separate `.tfvars` files:
```
terraform/environments/
├── dev.tfvars
├── staging.tfvars
└── prod.tfvars
```

### Enhanced Security Scanning

The pipeline already includes:
- ✅ **Checkov** security scanning with HTML reports
- ✅ **Automated summary generation** via shell scripts

Add to `pr-review.yml`:
- **tflint** for Terraform linting
- **Infracost** for cost estimation
- **KICS** for additional security checks

## 📚 Additional Resources

- [Complete Deployment Guide](./DEPLOYMENT_GUIDE.md) - Step-by-step setup instructions
- [Terraform Documentation](https://www.terraform.io/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Checkov Documentation](https://www.checkov.io/)

## 🐛 Troubleshooting

### Pipeline Fails on Terraform Init

**Check**:
- S3 bucket exists and name matches secret
- DynamoDB table exists with correct name
- AWS credentials have S3/DynamoDB permissions

### Checkov Scan Fails

**Solution**:
- Pipeline uses `--soft-fail` so it won't block deployment
- Review security warnings in the artifact
- Address critical findings for production

### Can't Access EKS Cluster

**Check**:
- AWS credentials are configured correctly
- EKS cluster is in "Active" state
- Node groups are healthy
- Update kubeconfig with correct cluster name and region

See [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) for more troubleshooting.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is open source and available under the MIT License.

## ✨ Features Coming Soon

- [ ] OIDC authentication (no static credentials)
- [ ] Cost estimation with Infracost
- [ ] Drift detection scheduled workflow
- [ ] Slack/Teams notifications
- [ ] Multi-environment support
- [ ] Terraform modules structure

---

**Made with ❤️ for DevOps Engineers**

For questions or issues, please open a GitHub issue.
