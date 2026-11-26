terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Terraform Cloud remote backend.
  # Workspace is set per environment in environments/*/backend.hcl or via CLI.
  # Never hardcode the Terraform Cloud token here. Configure it via:
  #   export TF_TOKEN_app_terraform_io=<token>
  # or   terraform login
  cloud {
    organization = "Tansim"
    workspaces {
      name = "DevOps"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "ap-southeast-1"
}

variable "environment" {
  description = "Deployment environment (dev, staging, production)"
  type        = string
}

variable "common_tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
    Project   = "Lab1-LB"
  }
}
