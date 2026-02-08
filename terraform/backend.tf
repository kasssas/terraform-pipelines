terraform {
  backend "s3" {
    # Backend configuration will be provided via -backend-config flags
    # in the GitHub Actions workflows
    # 
    # Example backend configuration:
    # bucket         = "your-terraform-state-bucket"
    # key            = "prod/terraform.tfstate"
    # region         = "us-east-1"
    # dynamodb_table = "terraform-state-lock"
    # encrypt        = true

    encrypt = true
  }
}
