# Terraform automatically loads every *.tf file in this directory and merges
# them into one configuration. Splitting main.tf / resource.tf / variable.tf
# is purely for human organization - Terraform doesn't require it.

terraform {
  required_version = ">=1.0.0"

  backend "s3" {
    bucket       = "streamflix-backends3-1995"
    key          = "dev/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


# No access_key/secret_key here on purpose. Terraform uses the same
# credential chain as the AWS CLI (environment variables, ~/.aws/credentials,
# an AWS CLI profile, etc.), so whatever identity `aws sts get-caller-identity`
# shows locally is the identity Terraform will use.

provider "aws" {
  region = "ap-south-1"
}