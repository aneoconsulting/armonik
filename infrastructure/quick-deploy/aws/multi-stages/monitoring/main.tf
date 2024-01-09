# AWS KMS
module "kms" {
  count  = (local.cloudwatch_kms_key_id == "" && local.cloudwatch_enabled ? 1 : 0)
  source = "../generated/infra-modules/security/aws/kms"
  name   = local.kms_name
  tags   = local.tags
}

# Seq
module "seq" {
  count         = (local.seq_enabled ? 1 : 0)
  source        = "../generated/infra-modules/monitoring/onpremise/seq"
  namespace     = var.namespace
  service_type  = local.seq_service_type
  port          = local.seq_port
  node_selector = local.seq_node_selector
  docker_image = {
    image              = local.seq_image
    tag                = local.seq_tag
    image_pull_secrets = local.seq_image_pull_secrets
  }
  docker_image_cron = {
    image              = local.cli_seq_image
    tag                = local.cli_seq_tag
    image_pull_secrets = local.cli_seq_image_pull_secrets
  }
  authentication    = var.authentication
  system_ram_target = local.seq_system_ram_target
  retention_in_days = local.retention_in_days
}

# node exporter
module "node_exporter" {
  count         = (local.node_exporter_enabled ? 1 : 0)
  source        = "../generated/infra-modules/monitoring/onpremise/exporters/node-exporter"
  namespace     = var.namespace
  node_selector = local.node_exporter_node_selector
  docker_image = {
    image              = local.node_exporter_image
    tag                = local.node_exporter_tag
    image_pull_secrets = local.node_exporter_image_pull_secrets
  }
}

# Metrics exporter
module "metrics_exporter" {
  source        = "../generated/infra-modules/monitoring/onpremise/exporters/metrics-exporter"
  namespace     = var.namespace
  service_type  = local.metrics_exporter_service_type
  node_selector = local.metrics_exporter_node_selector
  docker_image = {
    image              = local.metrics_exporter_image
    tag                = local.metrics_exporter_tag
    image_pull_secrets = local.metrics_exporter_image_pull_secrets
  }
  extra_conf = local.metrics_exporter_extra_conf
}

# Partition metrics exporter
#module "partition_metrics_exporter" {
#  source               = "../generated/infra-modules/monitoring/onpremise/exporters/partition-metrics-exporter"
#  namespace            = var.namespace
#  service_type         = local.partition_metrics_exporter_service_type
#  node_selector        = local.partition_metrics_exporter_node_selector
#  storage_endpoint_url = var.storage_endpoint_url
#  metrics_exporter_url = "${module.metrics_exporter.host}:${module.metrics_exporter.port}"
#  docker_image = {
#    image              = local.partition_metrics_exporter_image
#    tag                = local.partition_metrics_exporter_tag
#    image_pull_secrets = local.partition_metrics_exporter_image_pull_secrets
#  }
#  extra_conf  = local.partition_metrics_exporter_extra_conf
#  depends_on  = [module.metrics_exporter]
#}

# Prometheus
module "prometheus" {
  source               = "../generated/infra-modules/monitoring/onpremise/prometheus"
  namespace            = var.namespace
  service_type         = local.prometheus_service_type
  node_selector        = local.prometheus_node_selector
  metrics_exporter_url = "${module.metrics_exporter.host}:${module.metrics_exporter.port}"
  #"${module.partition_metrics_exporter.host}:${module.partition_metrics_exporter.port}"
  docker_image = {
    image              = local.prometheus_image
    tag                = local.prometheus_tag
    image_pull_secrets = local.prometheus_image_pull_secrets
  }
  persistent_volume = local.prometheus_persistent_volume
  depends_on = [
    module.prometheus_efs_persistent_volume,
    module.metrics_exporter,
    #module.partition_metrics_exporter
  ]
}

# Grafana
module "grafana" {
  count          = (local.grafana_enabled ? 1 : 0)
  source         = "../generated/infra-modules/monitoring/onpremise/grafana"
  namespace      = var.namespace
  service_type   = local.grafana_service_type
  port           = local.grafana_port
  node_selector  = local.grafana_node_selector
  prometheus_url = module.prometheus.url
  docker_image = {
    image              = local.grafana_image
    tag                = local.grafana_tag
    image_pull_secrets = local.grafana_image_pull_secrets
  }
  authentication    = var.authentication
  persistent_volume = local.grafana_persistent_volume
  depends_on = [
    module.prometheus,
  module.grafana_efs_persistent_volume]
}

# AWS EFS as persistent volume for Grafana
module "grafana_efs_persistent_volume" {
  count  = (try(var.monitoring.grafana.persistent_volume.storage_provisioner, "") == "efs.csi.aws.com" ? 1 : 0)
  source = "../generated/infra-modules/storage/aws/efs"
  efs = {
    name                            = local.grafana_efs_name
    kms_key_id                      = (var.grafana_efs.kms_key_id != "" && var.grafana_efs.kms_key_id != null ? var.grafana_efs.kms_key_id : module.kms[0].arn)
    performance_mode                = var.grafana_efs.performance_mode
    throughput_mode                 = var.grafana_efs.throughput_mode
    provisioned_throughput_in_mibps = var.grafana_efs.provisioned_throughput_in_mibps
    transition_to_ia                = var.grafana_efs.transition_to_ia
    access_point                    = var.grafana_efs.access_point
  }
  vpc  = local.vpc
  tags = local.tags
}

# AWS EFS as persistent volume for prometheus
module "prometheus_efs_persistent_volume" {
  count  = (try(var.monitoring.prometheus.persistent_volume.storage_provisioner, "") == "efs.csi.aws.com" ? 1 : 0)
  source = "../generated/infra-modules/storage/aws/efs"
  efs = {
    name                            = local.prometheus_efs_name
    kms_key_id                      = (var.prometheus_efs.kms_key_id != "" && var.prometheus_efs.kms_key_id != null ? var.prometheus_efs.kms_key_id : module.kms[0].arn)
    performance_mode                = var.prometheus_efs.performance_mode
    throughput_mode                 = var.prometheus_efs.throughput_mode
    provisioned_throughput_in_mibps = var.prometheus_efs.provisioned_throughput_in_mibps
    transition_to_ia                = var.prometheus_efs.transition_to_ia
    access_point                    = var.prometheus_efs.access_point
  }
  vpc  = local.vpc
  tags = local.tags
}
# CloudWatch
module "cloudwatch" {
  count             = (local.cloudwatch_enabled ? 1 : 0)
  source            = "../generated/infra-modules/monitoring/aws/cloudwatch-log-group"
  name              = local.cloudwatch_log_group_name
  kms_key_id        = (local.cloudwatch_kms_key_id != "" ? local.cloudwatch_kms_key_id : module.kms.0.arn)
  retention_in_days = local.cloudwatch_retention_in_days
  tags              = local.tags
}

# Fluent-bit
module "fluent_bit" {
  source        = "../generated/infra-modules/monitoring/onpremise/fluent-bit"
  namespace     = var.namespace
  node_selector = local.fluent_bit_node_selector
  fluent_bit = {
    container_name                  = "fluent-bit"
    image                           = local.fluent_bit_image
    tag                             = local.fluent_bit_tag
    image_pull_secrets              = local.fluent_bit_image_pull_secrets
    is_daemonset                    = local.fluent_bit_is_daemonset
    parser                          = local.fluent_bit_parser
    http_server                     = (local.fluent_bit_http_port == 0 ? "Off" : "On")
    http_port                       = (local.fluent_bit_http_port == 0 ? "" : tostring(local.fluent_bit_http_port))
    read_from_head                  = (local.fluent_bit_read_from_head ? "On" : "Off")
    read_from_tail                  = (local.fluent_bit_read_from_head ? "Off" : "On")
    fluentbitstate_hostpath         = var.monitoring.fluent_bit.fluentbitstate_hostpath
    varlibdockercontainers_hostpath = var.monitoring.fluent_bit.varlibdockercontainers_hostpath
    runlogjournal_hostpath          = var.monitoring.fluent_bit.runlogjournal_hostpath
  }
  seq = (local.seq_enabled ? {
    host    = module.seq.0.host
    port    = module.seq.0.port
    enabled = true
  } : {})
  cloudwatch = (local.cloudwatch_enabled ? {
    name    = module.cloudwatch.0.name
    region  = var.region
    enabled = true
  } : {})
  s3 = (local.s3_enabled ? {
    name    = local.s3_name
    region  = local.s3_region
    prefix  = local.suffix
    enabled = true
  } : {})
}
