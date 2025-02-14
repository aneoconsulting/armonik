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

module "rabbitmq" {
  count                 = var.rabbitmq != null ? 1 : 0
  source                = "./generated/infra-modules/storage/onpremise/rabbitmq"
  namespace             = local.namespace
  image                 = var.rabbitmq.image
  tag                   = try(coalesce(var.rabbitmq.tag), local.default_tags[var.rabbitmq.image])
  helm_chart_repository = try(coalesce(var.rabbitmq.helm_chart_repository), var.helm_charts.rabbitmq.repository)
  helm_chart_version    = try(coalesce(var.rabbitmq.helm_chart_verison), var.helm_charts.rabbitmq.version)
}

# MongoDB
module "mongodb" {
  count     = can(coalesce(var.mongodb_sharding)) ? 0 : 1
  source    = "./generated/infra-modules/storage/onpremise/mongodb"
  namespace = local.namespace
  mongodb = {
    image                 = var.mongodb.image_name
    tag                   = try(coalesce(var.mongodb.image_tag), local.default_tags[coalesce(var.mongodb.image_name, "bitnami/mongodb")])
    node_selector         = var.mongodb.node_selector
    image_pull_secrets    = var.mongodb.image_pull_secrets
    replicas              = var.mongodb.replicas
    helm_chart_repository = try(coalesce(var.mongodb.helm_chart_repository), var.helm_charts.mongodb.repository)
    helm_chart_version    = try(coalesce(var.mongodb.helm_chart_version), var.helm_charts.mongodb.version)
  }
  mongodb_resources = var.mongodb.mongodb_resources
  arbiter_resources = var.mongodb.arbiter_resources
  persistent_volume = var.mongodb.persistent_volume
}

module "mongodb_sharded" {
  count     = can(coalesce(var.mongodb_sharding)) ? 1 : 0
  source    = "./generated/infra-modules/storage/onpremise/mongodb-sharded"
  namespace = local.namespace

  mongodb = {
    image                 = var.mongodb.image_name
    tag                   = try(coalesce(var.mongodb.image_tag), local.default_tags[coalesce(var.mongodb.image_name, "bitnami/mongodb-sharded")])
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
}

# Redis
module "redis" {
  count     = var.redis != null ? 1 : 0
  source    = "./generated/infra-modules/storage/onpremise/redis"
  namespace = local.namespace
  redis = {
    image              = var.redis.image_name
    tag                = try(coalesce(var.redis.image_tag), local.default_tags[var.redis.image_name])
    node_selector      = var.redis.node_selector
    image_pull_secrets = var.redis.image_pull_secrets
    max_memory         = var.redis.max_memory
    max_memory_samples = var.redis.max_memory_samples
  }
}

# minio
module "minio" {
  count     = var.minio != null ? 1 : 0
  source    = "./generated/infra-modules/storage/onpremise/minio"
  namespace = local.namespace
  minio = {
    image              = var.minio.image_name
    tag                = try(coalesce(var.minio.image_tag), local.default_tags[var.minio.image_name])
    node_selector      = var.minio.node_selector
    image_pull_secrets = var.minio.image_pull_secrets
    host               = var.minio.host
    bucket_name        = var.minio.default_bucket
  }
}

# minio for file storage
module "minio_s3_fs" {
  count     = var.minio_s3_fs != null ? 1 : 0
  source    = "./generated/infra-modules/storage/onpremise/minio"
  namespace = local.namespace
  minio = {
    image              = local.minio_s3_fs_image
    tag                = try(coalesce(var.minio.image_tag), local.default_tags[var.minio_s3_fs.image_name])
    image_pull_secrets = local.minio_s3_fs_image_pull_secrets
    host               = local.minio_s3_fs_host
    bucket_name        = local.minio_s3_fs_bucket_name
    node_selector      = local.minio_s3_fs_node_selector
  }
}

#NFS
module "nfs" {
  count     = var.nfs != null ? 1 : 0
  source    = "./generated/infra-modules/storage/onpremise/nfs"
  image     = var.nfs.image
  tag       = try(coalesce(var.nfs.tag), local.default_tags[var.nfs.image])
  namespace = local.namespace
  server    = var.nfs.server
  path      = var.nfs.path
  pvc_name  = var.nfs.pvc_name
}
