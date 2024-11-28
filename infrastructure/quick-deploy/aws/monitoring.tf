locals {
  cloudwatch_log_group_name = "/aws/containerinsights/${module.eks.cluster_name}/application"
}

# Send logs in cloudwatch
data "aws_iam_policy_document" "send_logs_from_fluent_bit_to_cloudwatch_document" {
  count = var.cloudwatch != null ? 1 : 0
  statement {
    sid = "SendLogsFromFluentBitToCloudWatch"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
    ]
    effect = "Allow"
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:${local.cloudwatch_log_group_name}:*"
    ]
  }
}

resource "aws_iam_policy" "send_logs_from_fluent_bit_to_cloudwatch_policy" {
  count       = var.cloudwatch != null ? 1 : 0
  name_prefix = "send-logs-from-fluent-bit-to-cloudwatch-${module.eks.cluster_name}"
  description = "Policy for allowing send logs from fluent-bit  ${module.eks.cluster_name} to cloudwatch"
  policy      = data.aws_iam_policy_document.send_logs_from_fluent_bit_to_cloudwatch_document[0].json
  tags        = local.tags
}

resource "aws_iam_policy_attachment" "send_logs_from_fluent_bit_to_cloudwatch_attachment" {
  count      = length(aws_iam_policy.send_logs_from_fluent_bit_to_cloudwatch_policy)
  name       = "${local.prefix}-send-logs-from-fluent-bit-to-cloudwatch-${module.eks.cluster_name}"
  policy_arn = aws_iam_policy.send_logs_from_fluent_bit_to_cloudwatch_policy[0].arn
  roles      = module.eks.worker_iam_role_names
}

# Write objects in S3
data "aws_iam_policy_document" "write_object" {
  count = (var.s3.enabled ? 1 : 0)
  statement {
    sid = "WriteFromS3"
    actions = [
      "s3:PutObject"
    ]
    effect = "Allow"
    resources = [
      "${var.s3.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "write_object" {
  count       = (var.s3.enabled ? 1 : 0)
  name_prefix = "s3-logs-write-${module.eks.cluster_name}"
  description = "Policy for allowing read object in S3 logs ${module.eks.cluster_name}"
  policy      = data.aws_iam_policy_document.write_object[0].json
  tags        = local.tags
}


resource "aws_iam_policy_attachment" "write_object" {
  count      = (var.s3.enabled ? 1 : 0)
  name       = "s3-logs-write-${module.eks.cluster_name}"
  policy_arn = aws_iam_policy.write_object[0].arn
  roles      = module.eks.worker_iam_role_names
}

# Seq
module "seq" {
  count         = var.seq != null ? 1 : 0
  source        = "./generated/infra-modules/monitoring/onpremise/seq"
  namespace     = local.namespace
  service_type  = var.seq.service_type
  port          = var.seq.port
  node_selector = var.seq.node_selector
  docker_image = {
    image              = local.ecr_images["${var.seq.image_name}:${try(coalesce(var.seq.image_tag), "")}"].image
    tag                = local.ecr_images["${var.seq.image_name}:${try(coalesce(var.seq.image_tag), "")}"].tag
    image_pull_secrets = var.seq.pull_secrets
  }
  docker_image_cron = {
    image              = local.ecr_images["${var.seq.cli_image_name}:${try(coalesce(var.seq.cli_image_tag), "")}"].image
    tag                = local.ecr_images["${var.seq.cli_image_name}:${try(coalesce(var.seq.cli_image_tag), "")}"].tag
    image_pull_secrets = var.seq.pull_secrets
  }
  authentication    = var.seq.authentication
  system_ram_target = var.seq.system_ram_target
  retention_in_days = var.seq.retention_in_days
}

resource "kubernetes_secret" "seq" {
  metadata {
    name      = "seq"
    namespace = local.namespace
  }
  data = var.seq != null ? {
    host    = module.seq.0.host
    port    = module.seq.0.port
    url     = module.seq.0.url
    web_url = module.seq.0.web_url
    enabled = true
  } : {}
}

# node exporter
module "node_exporter" {
  count         = var.node_exporter != null ? 1 : 0
  source        = "./generated/infra-modules/monitoring/onpremise/exporters/node-exporter"
  namespace     = local.namespace
  node_selector = var.node_exporter.node_selector
  docker_image = {
    image              = local.ecr_images["${var.node_exporter.image_name}:${try(coalesce(var.node_exporter.image_tag), "")}"].image
    tag                = local.ecr_images["${var.node_exporter.image_name}:${try(coalesce(var.node_exporter.image_tag), "")}"].tag
    image_pull_secrets = var.node_exporter.pull_secrets
  }
}

# windows exporter
module "windows_exporter" {
  count         = var.windows_exporter != null ? 1 : 0
  source        = "./generated/infra-modules/monitoring/onpremise/exporters/windows-exporter"
  namespace     = local.namespace
  node_selector = var.windows_exporter.node_selector
  docker_image = {
    image              = local.ecr_images["${var.windows_exporter.image_name}:${try(coalesce(var.windows_exporter.image_tag), "")}"].image
    tag                = local.ecr_images["${var.windows_exporter.image_name}:${try(coalesce(var.windows_exporter.image_tag), "")}"].tag
    image_pull_secrets = var.windows_exporter.pull_secrets
  }
  init_docker_image = {
    image              = local.ecr_images["${var.windows_exporter.init_image_name}:${try(coalesce(var.windows_exporter.init_image_tag), "")}"].image
    tag                = local.ecr_images["${var.windows_exporter.init_image_name}:${try(coalesce(var.windows_exporter.init_image_tag), "")}"].tag
    image_pull_secrets = var.windows_exporter.init_pull_secrets
  }
}

# Metrics exporter
module "metrics_exporter" {
  source       = "./generated/infra-modules/monitoring/onpremise/exporters/metrics-exporter"
  namespace    = local.namespace
  service_type = var.metrics_exporter.service_type
}

resource "kubernetes_secret" "metrics_exporter" {
  metadata {
    name      = "metrics-exporter"
    namespace = local.namespace
  }
  data = {
    name      = module.metrics_exporter.name
    host      = module.metrics_exporter.host
    port      = module.metrics_exporter.port
    url       = module.metrics_exporter.url
    namespace = module.metrics_exporter.namespace
  }
}

# Partition metrics exporter
module "partition_metrics_exporter" {
  count                = var.partition_metrics_exporter != null ? 1 : 0
  source               = "./generated/infra-modules/monitoring/onpremise/exporters/partition-metrics-exporter"
  namespace            = local.namespace
  service_type         = var.partition_metrics_exporter.service_type
  node_selector        = var.partition_metrics_exporter.node_selector
  metrics_exporter_url = "${module.metrics_exporter.host}:${module.metrics_exporter.port}"
  docker_image = {
    image              = local.ecr_images["${var.partition_metrics_exporter.image_name}:${try(coalesce(var.partition_metrics_exporter.image_tag), "")}"].image
    tag                = local.ecr_images["${var.partition_metrics_exporter.image_name}:${try(coalesce(var.partition_metrics_exporter.image_tag), "")}"].tag
    image_pull_secrets = var.partition_metrics_exporter.pull_secrets
  }
  extra_conf = var.partition_metrics_exporter.extra_conf
  depends_on = [module.metrics_exporter]
}

resource "kubernetes_secret" "partition_metrics_exporter" {
  metadata {
    name      = "partition-metrics-exporter"
    namespace = local.namespace
  }
  data = var.partition_metrics_exporter != null ? {
    name      = module.partition_metrics_exporter.name
    host      = module.partition_metrics_exporter.host
    port      = module.partition_metrics_exporter.port
    url       = module.partition_metrics_exporter.url
    namespace = module.partition_metrics_exporter.namespace
  } : {}
}

# Prometheus
module "prometheus" {
  source               = "./generated/infra-modules/monitoring/onpremise/prometheus"
  namespace            = local.namespace
  service_type         = var.prometheus.service_type
  node_selector        = var.prometheus.node_selector
  metrics_exporter_url = "${module.metrics_exporter.host}:${module.metrics_exporter.port}"
  docker_image = {
    image              = local.ecr_images["${var.prometheus.image_name}:${try(coalesce(var.prometheus.image_tag), "")}"].image
    tag                = local.ecr_images["${var.prometheus.image_name}:${try(coalesce(var.prometheus.image_tag), "")}"].tag
    image_pull_secrets = var.prometheus.pull_secrets
  }

  persistent_volume = var.prometheus.persistent_volume != null ? {
    storage_provisioner = var.prometheus.persistent_volume.storage_provisioner
    volume_binding_mode = var.prometheus.persistent_volume.volume_binding_mode
    resources           = var.prometheus.persistent_volume.resources
    parameters = merge(var.prometheus.persistent_volume.parameters, try(var.prometheus.persistent_volume.storage_provisioner, "") == "efs.csi.aws.com" ? {
      provisioningMode = "efs-ap"
      fileSystemId     = module.prometheus_efs_persistent_volume[0].id
      directoryPerms   = "755"
      uid              = var.prometheus.security_context.run_as_user # optional
      gid              = var.prometheus.security_context.fs_group    # optional
      basePath         = "/prometheus"                               # optional
    } : {})
  } : null

  security_context = var.prometheus.security_context
}


module "prometheus_efs_persistent_volume" {
  count                           = (try(var.prometheus.persistent_volume.storage_provisioner, "") == "efs.csi.aws.com" ? 1 : 0)
  source                          = "./generated/infra-modules/storage/aws/efs"
  name                            = "${local.prefix}-prometheus"
  kms_key_id                      = try(coalesce(var.prometheus_efs.kms_key_id), local.kms_key)
  performance_mode                = var.prometheus_efs.performance_mode
  throughput_mode                 = var.prometheus_efs.throughput_mode
  provisioned_throughput_in_mibps = var.prometheus_efs.provisioned_throughput_in_mibps
  transition_to_ia                = var.prometheus_efs.transition_to_ia
  access_point                    = var.prometheus_efs.access_point
  vpc_id                          = local.vpc.id
  vpc_cidr_blocks                 = local.vpc.cidr_blocks
  vpc_cidr_block_private          = local.vpc.cidr_block_private
  vpc_subnet_ids                  = local.vpc.subnet_ids
  tags                            = local.tags
}

resource "kubernetes_secret" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = local.namespace
  }
  data = {
    host = module.prometheus.host
    port = module.prometheus.port
    url  = module.prometheus.url
  }
}

# Grafana
module "grafana" {
  count          = var.grafana != null ? 1 : 0
  source         = "./generated/infra-modules/monitoring/onpremise/grafana"
  namespace      = local.namespace
  service_type   = var.grafana.service_type
  port           = var.grafana.port
  node_selector  = var.grafana.node_selector
  prometheus_url = module.prometheus.url
  docker_image = {
    image              = local.ecr_images["${var.grafana.image_name}:${try(coalesce(var.grafana.image_tag), "")}"].image
    tag                = local.ecr_images["${var.grafana.image_name}:${try(coalesce(var.grafana.image_tag), "")}"].tag
    image_pull_secrets = var.grafana.pull_secrets
  }
  authentication = var.grafana.authentication

  persistent_volume = var.grafana.persistent_volume != null ? {
    storage_provisioner = var.grafana.persistent_volume.storage_provisioner
    volume_binding_mode = var.grafana.persistent_volume.volume_binding_mode
    resources           = var.grafana.persistent_volume.resources
    parameters = merge(var.grafana.persistent_volume.parameters, try(var.grafana.persistent_volume.storage_provisioner, "") == "efs.csi.aws.com" ? {
      provisioningMode = "efs-ap"
      fileSystemId     = module.grafana_efs_persistent_volume[0].id
      directoryPerms   = "755"
      uid              = var.grafana.security_context.run_as_user # optional
      gid              = var.grafana.security_context.fs_group    # optional
      basePath         = "/grafana"                               # optional
    } : {})
  } : null

  security_context = var.grafana.security_context
}


module "grafana_efs_persistent_volume" {
  count                           = (try(var.grafana.persistent_volume.storage_provisioner, "") == "efs.csi.aws.com" ? 1 : 0)
  source                          = "./generated/infra-modules/storage/aws/efs"
  name                            = "${local.prefix}-grafana"
  kms_key_id                      = try(coalesce(var.grafana_efs.kms_key_id), local.kms_key)
  performance_mode                = var.grafana_efs.performance_mode
  throughput_mode                 = var.grafana_efs.throughput_mode
  provisioned_throughput_in_mibps = var.grafana_efs.provisioned_throughput_in_mibps
  transition_to_ia                = var.grafana_efs.transition_to_ia
  access_point                    = var.grafana_efs.access_point
  vpc_id                          = local.vpc.id
  vpc_cidr_blocks                 = local.vpc.cidr_blocks
  vpc_cidr_block_private          = local.vpc.cidr_block_private
  vpc_subnet_ids                  = local.vpc.subnet_ids
  tags                            = local.tags
}

resource "kubernetes_secret" "grafana" {
  metadata {
    name      = "grafana"
    namespace = local.namespace
  }
  data = var.grafana != null ? {
    host    = module.grafana.0.host
    port    = module.grafana.0.port
    url     = module.grafana.0.url
    enabled = true
  } : {}
}

# CloudWatch
module "cloudwatch" {
  count             = var.cloudwatch != null ? 1 : 0
  source            = "./generated/infra-modules/monitoring/aws/cloudwatch-log-group"
  name              = local.cloudwatch_log_group_name
  kms_key_id        = local.kms_key
  retention_in_days = var.cloudwatch.retention_in_days
  tags              = local.tags
}

# Fluent-bit
module "fluent_bit" {
  source        = "./generated/infra-modules/monitoring/onpremise/fluent-bit"
  namespace     = local.namespace
  node_selector = var.fluent_bit.node_selector
  fluent_bit = {
    container_name                     = "fluent-bit"
    image                              = local.ecr_images["${var.fluent_bit.image_name}:${try(coalesce(var.fluent_bit.image_tag), "")}"].image
    tag                                = local.ecr_images["${var.fluent_bit.image_name}:${try(coalesce(var.fluent_bit.image_tag), "")}"].tag
    parser                             = var.fluent_bit.parser
    image_pull_secrets                 = var.fluent_bit.pull_secrets
    is_daemonset                       = var.fluent_bit.is_daemonset
    http_server                        = (var.fluent_bit.http_port == 0 ? "Off" : "On")
    http_port                          = (var.fluent_bit.http_port == 0 ? "" : tostring(var.fluent_bit.http_port))
    read_from_head                     = (var.fluent_bit.read_from_head ? "On" : "Off")
    read_from_tail                     = (var.fluent_bit.read_from_head ? "Off" : "On")
    fluent_bit_state_hostpath          = var.fluent_bit.fluent_bit_state_hostpath
    var_lib_docker_containers_hostpath = var.fluent_bit.var_lib_docker_containers_hostpath
    run_log_journal_hostpath           = var.fluent_bit.run_log_journal_hostpath
  }
  node_selector_windows = var.fluent_bit_windows.node_selector_windows
  fluent_bit_windows = {
    container_name                     = "fluent-bit-windows"
    image                              = local.ecr_images["${var.fluent_bit_windows.image_name}:${try(coalesce(var.fluent_bit_windows.image_tag), "")}"].image #var.fluent_bit_windows.image_name # 
    tag                                = local.ecr_images["${var.fluent_bit_windows.image_name}:${try(coalesce(var.fluent_bit_windows.image_tag), "")}"].tag   #var.fluent_bit_windows.image_tag  #
    parser                             = var.fluent_bit_windows.parser
    image_pull_secrets                 = var.fluent_bit_windows.pull_secrets
    is_daemonset                       = var.fluent_bit_windows.is_daemonset
    http_server                        = (var.fluent_bit_windows.http_port == 0 ? "Off" : "On")
    http_port                          = (var.fluent_bit_windows.http_port == 0 ? "" : tostring(var.fluent_bit_windows.http_port))
    read_from_head                     = (var.fluent_bit.read_from_head ? "On" : "Off")
    read_from_tail                     = (var.fluent_bit.read_from_head ? "Off" : "On")
    fluent_bit_state_hostpath          = var.fluent_bit.fluent_bit_state_hostpath
    var_lib_docker_containers_hostpath = var.fluent_bit_windows.var_lib_docker_containers_hostpath
    run_log_journal_hostpath           = var.fluent_bit_windows.run_log_journal_hostpath
  }
  seq = length(module.seq) != 0 ? {
    host    = module.seq[0].host
    port    = module.seq[0].port
    enabled = true
  } : {}
  cloudwatch = length(module.cloudwatch) != 0 ? {
    name    = module.cloudwatch[0].name
    region  = var.region
    enabled = true
  } : {}
  s3 = (var.s3.enabled ? {
    name    = var.s3.name
    region  = var.s3.region
    prefix  = local.prefix
    enabled = true
  } : {})
}

resource "kubernetes_secret" "fluent_bit" {
  metadata {
    name      = "fluent-bit"
    namespace = local.namespace
  }
  data = {
    is_daemonset = module.fluent_bit.is_daemonset
    name         = module.fluent_bit.container_name
    image        = module.fluent_bit.image
    tag          = module.fluent_bit.tag
    envvars      = module.fluent_bit.configmaps.envvars
    config       = module.fluent_bit.configmaps.config
  }
}

locals {
  monitoring = {
    seq = try({
      host    = module.seq[0].host
      port    = module.seq[0].port
      url     = module.seq[0].url
      web_url = module.seq[0].web_url
      enabled = true
    }, null)
    grafana = try({
      host    = module.grafana[0].host
      port    = module.grafana[0].port
      url     = module.grafana[0].url
      enabled = true
    }, null)
    prometheus = try({
      host = module.prometheus.host
      port = module.prometheus.port
      url  = module.prometheus.url
    }, null)
    metrics_exporter = try({
      name      = module.metrics_exporter.name
      host      = module.metrics_exporter.host
      port      = module.metrics_exporter.port
      url       = module.metrics_exporter.url
      namespace = module.metrics_exporter.namespace
    }, null)
    partition_metrics_exporter = try({
      name      = module.partition_metrics_exporter[0].name
      host      = module.partition_metrics_exporter[0].host
      port      = module.partition_metrics_exporter[0].port
      url       = module.partition_metrics_exporter[0].url
      namespace = module.partition_metrics_exporter[0].namespace
    }, null)
    cloudwatch = try({
      name    = module.cloudwatch[0].name
      region  = var.region
      enabled = true
    }, null)
    fluent_bit = try({
      container_name = module.fluent_bit.container_name
      image          = module.fluent_bit.image
      tag            = module.fluent_bit.tag
      is_daemonset   = module.fluent_bit.is_daemonset
      configmaps = {
        envvars = module.fluent_bit.configmaps.envvars
        config  = module.fluent_bit.configmaps.config
      }
    }, null)
  }
}
