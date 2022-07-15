terraform {
  required_version = "1.2.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.19.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.0.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.0.0"
    }
  }
  backend "s3" {}
}

provider "aws" {
  region  = "eu-central-1"
  access_key = "test"
  secret_key = "test"
  token      = "1c41f0e4-64d7-4c93-bd06-cc9ff1643007"
  profile = "default"
}