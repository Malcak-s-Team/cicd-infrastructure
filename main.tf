terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket         = "malakk-ci-terraform-state"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "malakk-ci-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region
}

module "backend" {
  source  = "./modules/tf-backend"
  project = "ci"
}

module "jenkins_state" {
  source = "./modules/s3"
  name   = "malcak-jenkins-state"
}
