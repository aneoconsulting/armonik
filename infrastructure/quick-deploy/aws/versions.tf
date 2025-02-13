terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.87"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.3"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.3"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.19.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.6"
    }
    pkcs12 = {
      source  = "chilicat/pkcs12"
      version = "~> 0.2.5"
    }
  }
}
