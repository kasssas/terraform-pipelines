# Terraform CI/CD Pipeline with GitHub Actions

A production-ready, automated infrastructure deployment pipeline using Terraform and GitHub Actions with comprehensive validation, security scanning, and manual approval gates.

## 🎯 Overview

This project implements a complete CI/CD pipeline for Terraform infrastructure with four distinct workflows:

1. **Development Validation** - Validates code quality on dev branch
2. **Pull Request Review** - Security scanning and plan generation for PRs
3. **Production Apply** - Deploys infrastructure with manual approval
4. **Manual Destroy** - Safely tears down infrastructure when needed

## 🏗️ Infrastructure

The included Terraform code deploys a basic AWS infrastructure for testing:

- **VPC** with CIDR 10.0.0.0/16
- **Public Subnet** with internet connectivity
- **Internet Gateway** and Route Tables
- **EC2 Instance** (t2.micro) running Apache web server
- **Security Groups** for SSH and HTTP access

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
│   └── workflows/
│       ├── dev-validation.yml        # Dev branch validation
│       ├── pr-review.yml             # PR security scan & plan
│       ├── production-apply.yml      # Production deployment
│       └── manual-destroy.yml        # Infrastructure teardown
├── terraform/
│   ├── main.tf                       # VPC, subnet, EC2 resources
│   ├── variables.tf                  # Input variables
│   ├── outputs.tf                    # Resource outputs
│   ├── backend.tf                    # S3 backend config
│   ├── versions.tf                   # Provider versions
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
environment        = "dev"
vpc_cidr           = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"
instance_type      = "t2.micro"
key_name           = "your-ssh-key-name"
allowed_ssh_cidr   = "0.0.0.0/0"  # Restrict to your IP for production
```

## 📈 Monitoring

### View Deployment Status

- **GitHub Actions**: Check workflow runs under the "Actions" tab
- **AWS Console**: Verify resources in VPC and EC2 dashboards
- **Terraform Outputs**: View in workflow summary or run `terraform output`

### Cost Monitoring

**Expected Monthly Cost**:
- EC2 t2.micro: ~$8-10/month (FREE with AWS Free Tier)
- VPC, subnet, IGW: Free
- S3, DynamoDB: < $1/month

**Set up billing alerts**:
1. AWS Console → CloudWatch → Billing
2. Create alarm for spend > $5/month

## 🧪 Testing

### Test the Web Server

After successful deployment:

1. Get the EC2 public IP from workflow output
2. Open browser: `http://[EC2_PUBLIC_IP]`
3. You should see a purple gradient page with deployment details

### Test SSH Access

```bash
ssh -i your-key.pem ec2-user@[EC2_PUBLIC_IP]
```

## 🔧 Customization

### Add More Resources

Edit `terraform/main.tf` to add:
- RDS databases
- Load balancers
- Auto-scaling groups
- CloudFront distributions
- S3 buckets

### Multi-Environment Support

Create separate `.tfvars` files:
```
terraform/environments/
├── dev.tfvars
├── staging.tfvars
└── prod.tfvars
```

### Enhanced Security Scanning

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

### Can't Access Web Server

**Check**:
- Wait 2-3 minutes for user_data script to complete
- Verify security group allows HTTP (port 80)
- Ensure you're using `http://` not `https://`
- Check instance is in "running" state

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
For questions or issues, please open a GitHub issue.

a
