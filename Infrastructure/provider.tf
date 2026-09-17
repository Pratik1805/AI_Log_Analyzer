# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    bucket       = "devops-tf-state-pratik-12345"
    key          = "terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
    encrypt      = true
  }
}
