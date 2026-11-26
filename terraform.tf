terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # NOTE: This root module intentionally does NOT configure a Terraform Cloud
  # workspace. Each environment under environments/ is a separate root module
  # with its own remote backend configuration (dev / staging / production
  # workspaces in the "Tansim" organization).
  #
  # Never hardcode the Terraform Cloud token in this file. Configure it securely
  # via one of these methods before running terraform in an environment:
  #
  #   export TF_TOKEN_app_terraform_io=<YOUR_TFC_TOKEN>
  #   terraform login
  #
  # Then select an environment directory and run:
  #   terraform init   # selects the workspace named in that environment
  #   terraform validate
  #   terraform plan
}

provider "aws" {
  region = "ap-southeast-1"
}
