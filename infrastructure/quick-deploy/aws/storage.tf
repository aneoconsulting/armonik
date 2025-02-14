# AWS S3 as shared storage
module "s3_fs" {
  source = "./generated/infra-modules/storage/aws/s3"
  tags   = local.tags
  name   = "${local.prefix}-s3fs"

  policy                                = var.s3_fs.policy
  attach_policy                         = var.s3_fs.attach_policy
  attach_deny_insecure_transport_policy = var.s3_fs.attach_deny_insecure_transport_policy
  attach_require_latest_tls_policy      = var.s3_fs.attach_require_latest_tls_policy
  attach_public_policy                  = var.s3_fs.attach_public_policy
  block_public_acls                     = var.s3_fs.attach_public_policy
  block_public_policy                   = var.s3_fs.block_public_acls
  ignore_public_acls                    = var.s3_fs.block_public_policy
  restrict_public_buckets               = var.s3_fs.restrict_public_buckets
  kms_key_id                            = local.kms_key
  sse_algorithm                         = can(coalesce(var.kms_key)) ? var.s3_fs.sse_algorithm : "aws:kms"
  ownership                             = var.s3_fs.ownership
  versioning                            = var.s3_fs.versioning
  role_name                             = module.aws_service_account.service_account_iam_role_name
}

# Shared storage
resource "kubernetes_secret" "shared_storage" {
  metadata {
    name      = "shared-storage"
    namespace = local.namespace
  }
  data = {
    service_url           = "https://s3.${var.region}.amazonaws.com"
    kms_key_id            = module.s3_fs.kms_key_id
    name                  = module.s3_fs.s3_bucket_name
    access_key_id         = ""
    secret_access_key     = ""
    file_storage_type     = "S3"
    must_force_path_style = false
    use_chunk_encoding    = true
    use_check_sum         = true
  }
}

# AWS S3 as object storage
module "s3_os" {
  count  = var.s3_os != null ? 1 : 0
  source = "./generated/infra-modules/storage/aws/s3"
  tags   = local.tags
  name   = "${local.prefix}-s3os"

  policy                                = var.s3_os.policy
  attach_policy                         = var.s3_os.attach_policy
  attach_deny_insecure_transport_policy = var.s3_os.attach_deny_insecure_transport_policy
  attach_require_latest_tls_policy      = var.s3_os.attach_require_latest_tls_policy
  attach_public_policy                  = var.s3_os.attach_public_policy
  block_public_acls                     = var.s3_os.attach_public_policy
  block_public_policy                   = var.s3_os.block_public_acls
  ignore_public_acls                    = var.s3_os.block_public_policy
  restrict_public_buckets               = var.s3_os.restrict_public_buckets
  kms_key_id                            = local.kms_key
  sse_algorithm                         = can(coalesce(var.kms_key)) ? var.s3_os.sse_algorithm : "aws:kms"
  ownership                             = var.s3_os.ownership
  versioning                            = var.s3_os.versioning
}

resource "kubernetes_secret" "s3" {
  count = length(module.s3_os) > 0 ? 1 : 0
  metadata {
    name      = "s3"
    namespace = local.namespace
  }
  data = {
    username              = ""
    password              = ""
    url                   = "https://s3.${var.region}.amazonaws.com"
    bucket_name           = module.s3_os[0].s3_bucket_name
    kms_key_id            = module.s3_os[0].kms_key_id
    must_force_path_style = false
    use_chunk_encoding    = true
    use_check_sum         = true
  }
}

# AWS Elasticache
module "elasticache" {
  count           = var.elasticache != null ? 1 : 0
  source          = "./generated/infra-modules/storage/aws/elasticache"
  tags            = local.tags
  name            = "${local.prefix}-elasticache"
  vpc_id          = local.vpc.id
  vpc_cidr_blocks = local.vpc.cidr_blocks
  vpc_subnet_ids  = local.vpc.subnet_ids

  engine                      = var.elasticache.engine
  engine_version              = var.elasticache.engine_version
  node_type                   = var.elasticache.node_type
  apply_immediately           = var.elasticache.apply_immediately
  multi_az_enabled            = var.elasticache.multi_az_enabled
  automatic_failover_enabled  = var.elasticache.automatic_failover_enabled
  num_cache_clusters          = var.elasticache.num_cache_clusters
  preferred_cache_cluster_azs = var.elasticache.preferred_cache_cluster_azs
  data_tiering_enabled        = var.elasticache.data_tiering_enabled
  log_retention_in_days       = var.elasticache.log_retention_in_days
  max_memory_samples          = var.elasticache.max_memory_samples

  kms_key_id     = local.kms_key
  log_kms_key_id = local.kms_key
}

resource "kubernetes_secret" "elasticache" {
  count = length(module.elasticache) > 0 ? 1 : 0
  metadata {
    name      = "redis"
    namespace = local.namespace
  }
  data = {
    "chain.pem" = ""
    username    = ""
    password    = ""
    host        = module.elasticache[0].endpoint_host
    port        = module.elasticache[0].endpoint_port
    url         = module.elasticache[0].endpoint_url
  }
}

# Amazon MQ
module "mq" {
  count           = var.activemq == null ? 1 : 0
  source          = "./generated/infra-modules/storage/aws/mq"
  tags            = local.tags
  name            = "${local.prefix}-mq"
  namespace       = local.namespace
  vpc_id          = local.vpc.id
  vpc_cidr_blocks = local.vpc.cidr_blocks
  vpc_subnet_ids  = local.vpc.subnet_ids
  username        = var.mq_credentials.username
  password        = var.mq_credentials.password

  engine_type             = var.mq.engine_type
  engine_version          = var.mq.engine_version
  host_instance_type      = var.mq.host_instance_type
  apply_immediately       = var.mq.apply_immediately
  deployment_mode         = var.mq.deployment_mode
  storage_type            = var.mq.storage_type
  authentication_strategy = var.mq.authentication_strategy
  publicly_accessible     = var.mq.publicly_accessible
  kms_key_id              = local.kms_key
}

# ActiveMQ
module "activemq" {
  count     = var.activemq != null ? 1 : 0
  source    = "./generated/infra-modules/storage/onpremise/activemq"
  namespace = local.namespace
  activemq = {
    image                = var.activemq.image_name
    tag                  = try(coalesce(var.activemq.image_tag), local.default_tags[var.activemq.image_name])
    node_selector        = var.activemq.node_selector
    image_pull_secrets   = var.activemq.image_pull_secrets
    limits               = var.activemq.limits
    requests             = var.activemq.requests
    activemq_opts_memory = var.activemq.activemq_opts_memory
  }
}

module "aws_service_account" {
  namespace         = local.namespace
  source            = "./generated/infra-modules/service-account/aws"
  prefix            = local.prefix
  name              = "armonikserviceaccount"
  oidc_provider_arn = module.eks.aws_eks_module.oidc_provider_arn
  oidc_issuer_url   = module.eks.aws_eks_module.cluster_oidc_issuer_url
}

# MongoDB
module "mongodb" {
  count     = can(coalesce(var.mongodb_sharding)) ? 0 : 1
  source    = "./generated/infra-modules/storage/onpremise/mongodb"
  namespace = local.namespace
  mongodb = {
    image                 = local.ecr_images["${local.mongodb_image_name}:${try(coalesce(var.mongodb.image_tag), "")}"].name
    tag                   = local.ecr_images["${local.mongodb_image_name}:${try(coalesce(var.mongodb.image_tag), "")}"].tag
    node_selector         = var.mongodb.node_selector
    image_pull_secrets    = var.mongodb.image_pull_secrets
    replicas              = var.mongodb.replicas
    helm_chart_repository = try(coalesce(var.mongodb.helm_chart_repository), var.helm_charts.mongodb.repository)
    helm_chart_version    = try(coalesce(var.mongodb.helm_chart_version), var.helm_charts.mongodb.version)
  }

  persistent_volume = var.mongodb.persistent_volume != null ? {
    storage_provisioner = var.mongodb.persistent_volume.storage_provisioner
    access_mode         = var.mongodb.persistent_volume.acces_mode
    reclaim_policy      = var.mongodb.persistent_volume.reclaim_policy
    volume_binding_mode = var.mongodb.persistent_volume.volume_binding_mode
    resources           = var.mongodb.persistent_volume.resources
    parameters = merge(var.mongodb.persistent_volume.parameters, try(var.mongodb.persistent_volume.storage_provisioner, "") == "efs.csi.aws.com" ? {
      provisioningMode = "efs-ap"
      fileSystemId     = module.mongodb_efs_persistent_volume[0].id
      directoryPerms   = "755"
      uid              = var.mongodb.security_context.run_as_user # optional
      gid              = var.mongodb.security_context.fs_group    # optional
      basePath         = "/mongodb"                               # optional
    } : {})
  } : null

  security_context  = var.mongodb.security_context
  mongodb_resources = var.mongodb.mongodb_resources
  arbiter_resources = var.mongodb.arbiter_resources

}

module "mongodb_sharded" {
  count     = can(coalesce(var.mongodb_sharding)) ? 1 : 0
  source    = "./generated/infra-modules/storage/onpremise/mongodb-sharded"
  namespace = local.namespace

  mongodb = {
    image                 = local.ecr_images["${local.mongodb_image_name}:${try(coalesce(var.mongodb.image_tag), "")}"].name
    tag                   = local.ecr_images["${local.mongodb_image_name}:${try(coalesce(var.mongodb.image_tag), "")}"].tag
    node_selector         = var.mongodb.node_selector
    image_pull_secrets    = var.mongodb.image_pull_secrets
    helm_chart_repository = try(coalesce(var.mongodb.helm_chart_repository), var.helm_charts["mongodb-sharded"].repository)
    helm_chart_version    = try(coalesce(var.mongodb.helm_chart_version), var.helm_charts["mongodb-sharded"].version)
  }

  # All the try(coalesce()) are there to use values from the mongodb variable if the attributes are not defined in the mongodb_sharding variables
  sharding = {
    shards = {
      quantity      = try(coalesce(var.mongodb_sharding.shards.quantity), null)
      replicas      = try(coalesce(var.mongodb_sharding.shards.replicas), var.mongodb.replicas)
      node_selector = try(coalesce(var.mongodb_sharding.shards.node_selector), var.mongodb.node_selector)
    }

    arbiter = {
      node_selector = try(coalesce(var.mongodb_sharding.arbiter.node_selector), var.mongodb.node_selector)
    }

    router = merge(var.mongodb_sharding.router, {
      replicas      = try(coalesce(var.mongodb_sharding.router.replicas), null)
      node_selector = try(coalesce(var.mongodb_sharding.router.node_selector), var.mongodb.node_selector)
    })

    configsvr = {
      replicas      = try(coalesce(var.mongodb_sharding.configsvr.replicas), null)
      node_selector = try(coalesce(var.mongodb_sharding.configsvr.node_selector), var.mongodb.node_selector)
    }
  }

  resources = {
    shards    = try(coalesce(var.mongodb_sharding.shards.resources), var.mongodb.mongodb_resources)
    arbiter   = try(coalesce(var.mongodb_sharding.arbiter.resources), var.mongodb.arbiter_resources)
    configsvr = try(coalesce(var.mongodb_sharding.configsvr.resources), null)
    router    = try(coalesce(var.mongodb_sharding.router.resources), null)
  }

  labels = {
    shards    = try(coalesce(var.mongodb_sharding.shards.labels), null)
    arbiter   = try(coalesce(var.mongodb_sharding.arbiter.labels), null)
    configsvr = try(coalesce(var.mongodb_sharding.configsvr.labels), null)
    router    = try(coalesce(var.mongodb_sharding.router.labels), null)
  }

  persistence = can(try(coalesce(var.mongodb_sharding.persistence), coalesce(var.mongodb.persistent_volume))) ? {
    shards = can(try(coalesce(var.mongodb_sharding.persistence.shards), coalesce(var.mongodb.persistent_volume))) ? {
      storage_provisioner = try(coalesce(var.mongodb_sharding.persistence.shards.storage_provisioner), coalesce(var.mongodb.persistent_volume.storage_provisioner), null)
      volume_binding_mode = try(coalesce(var.mongodb_sharding.persistence.shards.volume_binding_mode), coalesce(var.mongodb.persistent_volume.volume_binding_mode), null)
      reclaim_policy      = try(coalesce(var.mongodb_sharding.persistence.shards.reclaim_policy), coalesce(var.mongodb.persistent_volume.reclaim_policy), null)
      resources           = try(coalesce(var.mongodb_sharding.persistence.shards.resources), coalesce(var.mongodb.persistent_volume.resources), null)
      parameters          = local.mongodb_storage_class_parameters
    } : null

    configsvr = can(coalesce(var.mongodb_sharding.persistence.configsvr)) ? {
      storage_provisioner = var.mongodb_sharding.persistence.configsvr.storage_provisioner
      volume_binding_mode = var.mongodb_sharding.persistence.configsvr.volume_binding_mode
      reclaim_policy      = var.mongodb_sharding.persistence.configsvr.reclaim_policy
      resources           = var.mongodb_sharding.persistence.configsvr.resources
      parameters          = local.configsvr_storage_class_parameters
    } : null
  } : null
}

module "mongodb_efs_persistent_volume" {
  count                           = try(coalesce(var.mongodb_sharding.persistence.shards.storage_provisioner), coalesce(var.mongodb.persistent_volume.storage_provisioner), "") == "efs.csi.aws.com" ? 1 : 0
  source                          = "./generated/infra-modules/storage/aws/efs"
  name                            = "${local.prefix}-mongodb"
  kms_key_id                      = try(coalesce(var.mongodb_efs.kms_key_id), local.kms_key)
  performance_mode                = var.mongodb_efs.performance_mode
  throughput_mode                 = var.mongodb_efs.throughput_mode
  provisioned_throughput_in_mibps = var.mongodb_efs.provisioned_throughput_in_mibps
  transition_to_ia                = var.mongodb_efs.transition_to_ia
  access_point                    = var.mongodb_efs.access_point
  vpc_id                          = local.vpc.id
  vpc_cidr_blocks                 = local.vpc.cidr_blocks
  vpc_cidr_block_private          = local.vpc.cidr_block_private
  vpc_subnet_ids                  = local.vpc.subnet_ids
  tags                            = local.tags
}

module "configsvr_efs_persistent_volume" {
  count                           = (try(var.mongodb_sharding.persistence.configsvr.storage_provisioner, "") == "efs.csi.aws.com" ? 1 : 0)
  source                          = "./generated/infra-modules/storage/aws/efs"
  name                            = "${local.prefix}-mongodb-configsvr"
  kms_key_id                      = try(coalesce(var.mongodb_efs.kms_key_id), local.kms_key)
  performance_mode                = var.mongodb_efs.performance_mode
  throughput_mode                 = var.mongodb_efs.throughput_mode
  provisioned_throughput_in_mibps = var.mongodb_efs.provisioned_throughput_in_mibps
  transition_to_ia                = var.mongodb_efs.transition_to_ia
  access_point                    = var.mongodb_efs.access_point
  vpc_id                          = local.vpc.id
  vpc_cidr_blocks                 = local.vpc.cidr_blocks
  vpc_cidr_block_private          = local.vpc.cidr_block_private
  vpc_subnet_ids                  = local.vpc.subnet_ids
  tags                            = local.tags
}


resource "aws_iam_policy_attachment" "armonik_decrypt_object" {
  name       = "storage-s3-encrypt-decrypt-armonik"
  roles      = [module.aws_service_account.service_account_iam_role_name]
  policy_arn = aws_iam_policy.decrypt_object.arn
}


# Decrypt objects in S3
data "aws_iam_policy_document" "decrypt_object" {
  statement {
    sid = "KMSAccess"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    effect = "Allow"
    resources = toset([
      for _, s3 in local.aws_s3 :
      s3.kms_key_id
    ])
  }
}

resource "aws_iam_policy" "decrypt_object" {
  name_prefix = "${local.prefix}-s3-encrypt-decrypt"
  description = "Policy for alowing decryption of encrypted object in S3 ${module.eks.cluster_name}"
  policy      = data.aws_iam_policy_document.decrypt_object.json
  tags        = local.tags
}

resource "aws_iam_policy_attachment" "decrypt_object" {
  name       = "${local.prefix}-s3-encrypt-decrypt"
  roles      = module.eks.worker_iam_role_names
  policy_arn = aws_iam_policy.decrypt_object.arn
}

# object permissions for S3
data "aws_iam_policy_document" "object" {
  for_each = local.aws_s3
  statement {
    sid     = each.value.permission_sid
    actions = each.value.permission_actions
    effect  = "Allow"
    resources = [
      "${each.value.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "object" {
  for_each    = data.aws_iam_policy_document.object
  name_prefix = "${local.prefix}-s3-${each.key}"
  description = "Policy for allowing object access in ${each.key} S3 ${module.eks.cluster_name}"
  policy      = each.value.json
  tags        = local.tags
}

resource "aws_iam_policy_attachment" "object" {
  for_each   = aws_iam_policy.object
  name       = "${local.prefix}-permissions-on-s3-${each.key}"
  roles      = module.eks.worker_iam_role_names
  policy_arn = each.value.arn
}

locals {
  aws_s3 = merge(
    {
      fs = merge(
        module.s3_fs,
        {
          permission_sid = "ReadFromS3"
          permission_actions = [
            "s3:GetObject"
          ]
        }
      )
    },
    length(module.s3_os) == 0 ? {} : {
      os = merge(
        module.s3_os[0],
        {
          permission_sid = "FullAccessFromS3"
          permission_actions = [
            "s3:PutObject",
            "s3:GetObject",
            "s3:ListBucket",
            "s3:DeleteObject",
            "s3:PutObjectAcl",
            "s3:PutObjectTagging",
          ]
        }
      )
    },
  )
  shared_storage = {
    file_storage_type     = "S3"
    service_url           = "https://s3.${var.region}.amazonaws.com"
    access_key_id         = ""
    secret_access_key     = ""
    name                  = module.s3_fs.s3_bucket_name
    must_force_path_style = false
    use_chunk_encoding    = true
    use_check_sum         = true
  }

  # Ensures some mandatory storage class parameters are effectively passed when persistence is enabled
  mongodb_storage_class_parameters = merge(
    try(coalesce(var.mongodb_sharding.persistence.shards.storage_provisioner), coalesce(var.mongodb.persistent_volume.storage_provisioner), "") == "efs.csi.aws.com" ? {
      provisioningMode = "efs-ap"
      fileSystemId     = module.mongodb_efs_persistent_volume[0].id
      directoryPerms   = "755"
      uid              = var.mongodb.security_context.run_as_user # optional
      gid              = var.mongodb.security_context.fs_group    # optional
      basePath         = "/mongodb"                               # optional
    } : try(coalesce(var.mongodb_sharding.persistence.shards.storage_provisioner), coalesce(var.mongodb.persistent_volume.storage_provisioner), "") == "ebs.csi.aws.com" ?
    {
      "csi.storage.k8s.io/fstype" = "xfs"
      "type"                      = "gp3"
      "iopsPerGB"                 = 500
    } : null,
    try(coalesce(var.mongodb_sharding.persistence.shards.parameters), coalesce(var.mongodb.persistent_volume.parameters), null)
  )

  configsvr_storage_class_parameters = merge(
    try(var.mongodb_sharding.persistence.configsvr.storage_provisioner, "") == "efs.csi.aws.com" ? {
      provisioningMode = "efs-ap"
      fileSystemId     = module.configsvr_efs_persistent_volume[0].id
      directoryPerms   = "755"
      uid              = var.mongodb.security_context.run_as_user # optional
      gid              = var.mongodb.security_context.fs_group    # optional
      basePath         = "/mongodb"                               # optional
    } : try(var.mongodb_sharding.persistence.configsvr.storage_provisioner, "") == "ebs.csi.aws.com" ?
    {
      "csi.storage.k8s.io/fstype" = "ext4"
      "type"                      = "gp3"
      "iopsPerGB"                 = 200
    } : null,
    try(var.mongodb_sharding.persistence.configsvr.parameters, null)
  )
}
