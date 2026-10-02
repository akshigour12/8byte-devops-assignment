provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "8byte-devops-assignment"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
