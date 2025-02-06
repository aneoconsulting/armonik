terraform {
  backend "local" {
    path          = "./generated/backend/terraform.tfstate"
    workspace_dir = "armonik"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.76.1"
    }

    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = var.tags
  }
}