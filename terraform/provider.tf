terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.54.1"
    }
  }
}

provider "aws" {
  # Configuration options
  access_key = ""
  secret_key = ""
  region = var.aws_region
}