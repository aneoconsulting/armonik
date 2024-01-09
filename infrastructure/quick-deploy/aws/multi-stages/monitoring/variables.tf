# Profile
variable "profile" {
  description = "Profile of AWS credentials to deploy Terraform sources"
  type        = string
  default     = "default"
}

# Region
variable "region" {
  description = "AWS region where the infrastructure will be deployed"
  type        = string
  default     = "eu-west-3"
}

# Aws account id
variable "aws_account_id" {
  description = "AWS account ID where the infrastructure will be deployed"
  type        = string
}

# Kubeconfig path
variable "k8s_config_path" {
  description = "Path of the configuration file of K8s"
  type        = string
  default     = "~/.kube/config"
}

# Kubeconfig context
variable "k8s_config_context" {
  description = "Context of K8s"
  type        = string
  default     = "default"
}

# SUFFIX
variable "suffix" {
  description = "To suffix the AWS resources"
  type        = string
  default     = ""
}

# AWS TAGs
variable "tags" {
  description = "Tags for AWS resources"
  type        = any
  default     = {}
}

# Kubernetes namespace
variable "namespace" {
  description = "Kubernetes namespace for ArmoniK"
  type        = string
  default     = "armonik"
}

# EKS info
variable "eks" {
  description = "EKS info"
  type        = any
  default     = {}
}

# VPC infos
variable "vpc" {
  description = "AWS VPC info"
  type        = any
}

# List of needed storage
variable "storage_endpoint_url" {
  description = "List of storage needed by ArmoniK"
  type        = any
  default     = {}
}

# Monitoring infos
variable "monitoring" {
  description = "Monitoring infos"
  type = object({
    seq = object({
      enabled                = bool
      image                  = string
      tag                    = string
      port                   = number
      image_pull_secrets     = string
      service_type           = string
      node_selector          = any
      system_ram_target      = number
      cli_image              = string
      cli_tag                = string
      cli_image_pull_secrets = string
      retention_in_days      = string
    })
    grafana = object({
      enabled            = bool
      image              = string
      tag                = string
      port               = number
      image_pull_secrets = string
      service_type       = string
      node_selector      = any
      persistent_volume = object({
        storage_provisioner = string
        parameters          = map(string)
        #Resources for PVC
        resources = object({
          limits = object({
            storage = string
          })
          requests = object({
            storage = string
          })
        })
      })
    })
    node_exporter = object({
      enabled            = bool
      image              = string
      tag                = string
      image_pull_secrets = string
      node_selector      = any
    })
    prometheus = object({
      image              = string
      tag                = string
      image_pull_secrets = string
      service_type       = string
      node_selector      = any
      persistent_volume = object({
        storage_provisioner = string
        parameters          = map(string)
        #Resources for PVC
        resources = object({
          limits = object({
            storage = string
          })
          requests = object({
            storage = string
          })
        })
      })
    })
    metrics_exporter = object({
      image              = string
      tag                = string
      image_pull_secrets = string
      service_type       = string
      node_selector      = any
      extra_conf         = map(string)
    })
    partition_metrics_exporter = object({
      image              = string
      tag                = string
      image_pull_secrets = string
      service_type       = string
      node_selector      = any
      extra_conf         = map(string)
    })
    cloudwatch = object({
      enabled           = bool
      kms_key_id        = string
      retention_in_days = number
    })
    s3 = object({
      enabled = bool
      name    = string
      region  = string
      arn     = string
      prefix  = string
    })
    fluent_bit = object({
      image                           = string
      tag                             = string
      image_pull_secrets              = string
      is_daemonset                    = bool
      http_port                       = number
      read_from_head                  = string
      node_selector                   = any
      parser                          = string
      fluentbitstate_hostpath         = string
      varlibdockercontainers_hostpath = string
      runlogjournal_hostpath          = string
    })
  })
}

# Enable authentication of seq and grafana
variable "authentication" {
  description = "Enable authentication form in seq and grafana"
  type        = bool
  default     = false
}

# AWS EFS as Persistent volume for Grafana
variable "grafana_efs" {
  description = "AWS EFS as Persistent volume for Grafana"
  type = object({
    name                            = string
    kms_key_id                      = string
    performance_mode                = string # "generalPurpose" or "maxIO"
    throughput_mode                 = string #  "bursting" or "provisioned"
    provisioned_throughput_in_mibps = number
    transition_to_ia                = string
    # "AFTER_7_DAYS", "AFTER_14_DAYS", "AFTER_30_DAYS", "AFTER_60_DAYS", or "AFTER_90_DAYS"
    access_point = list(string)
  })
}

# AWS EFS as Persistent volume for Prometheus
variable "prometheus_efs" {
  description = "AWS EFS as Persistent volume for Prometheus"
  type = object({
    name                            = string
    kms_key_id                      = string
    performance_mode                = string # "generalPurpose" or "maxIO"
    throughput_mode                 = string #  "bursting" or "provisioned"
    provisioned_throughput_in_mibps = number
    transition_to_ia                = string
    # "AFTER_7_DAYS", "AFTER_14_DAYS", "AFTER_30_DAYS", "AFTER_60_DAYS", or "AFTER_90_DAYS"
    access_point = list(string)
  })
}