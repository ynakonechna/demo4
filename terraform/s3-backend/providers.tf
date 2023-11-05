provider "aws" {
  region = "us-west-2"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.18.1"
    }
  }

  backend "s3" {
    bucket         	   = "terraform-s3-backend-demo2"
    key              	   = "state/terraform.tfstate"
    region         	   = "us-west-2"
    encrypt        	   = true
    dynamodb_table = "terraform-s3-backend-demo2"
  }
}