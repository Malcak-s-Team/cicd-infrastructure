terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket         = "malakk-cicd-us-east-1-terraform-state"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "malakk-cicd-us-east-1-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region
}

data "aws_iam_account_alias" "current" {}

module "backend" {
  source         = "github.com/Malcak/terraform-s3-backend.git"
  bucket_purpose = "cicd"
  accout_alias   = data.aws_iam_account_alias.current.account_alias
  region         = var.region
}

module "jenkins_state" {
  source = "./modules/s3"
  name   = "${data.aws_iam_account_alias.current.account_alias}-jenkins-backups"
}
