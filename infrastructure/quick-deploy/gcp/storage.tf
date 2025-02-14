locals {
  region = coalesce(var.region, data.google_client_config.current.region)
  shared_storage = {
    file_storage_type     = "S3"
    service_url           = "https://storage.googleapis.com"
    access_key_id         = google_storage_hmac_key.cloud_storage.access_id
    secret_access_key     = google_storage_hmac_key.cloud_storage.secret
    name                  = module.gcs_fs.name
    must_force_path_style = false
    use_chunk_encoding    = false
    use_check_sum         = false
  }
}

# MongoDB for state-database
module "mongodb" {
  count     = can(coalesce(var.mongodb_sharding)) ? 0 : 1
  source    = "./generated/infra-modules/storage/onpremise/mongodb"
  namespace = local.namespace
  mongodb = {
    image                 = local.docker_images["${local.mongodb_image_name}:${try(coalesce(var.mongodb.image_tag), "")}"].name
    tag                   = local.docker_images["${local.mongodb_image_name}:${try(coalesce(var.mongodb.image_tag), "")}"].tag
    node_selector         = var.mongodb.node_selector
    image_pull_secrets    = var.mongodb.pull_secrets
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
    image                 = local.docker_images["${local.mongodb_image_name}:${try(coalesce(var.mongodb.image_tag), "")}"].name
    tag                   = local.docker_images["${local.mongodb_image_name}:${try(coalesce(var.mongodb.image_tag), "")}"].tag
    node_selector         = var.mongodb.node_selector
    image_pull_secrets    = var.mongodb.pull_secrets
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

# Redis for payloads
module "memorystore" {
  count              = var.memorystore != null ? 1 : 0
  source             = "./generated/infra-modules/storage/gcp/memorystore/redis"
  name               = "${local.prefix}-redis"
  namespace          = local.namespace
  memory_size_gb     = var.memorystore.memory_size_gb
  auth_enabled       = var.memorystore.auth_enabled
  authorized_network = module.vpc.name
  connect_mode       = var.memorystore.connect_mode
  display_name       = "${local.prefix}-redis"
  labels             = local.labels
  locations = var.memorystore.tier == "STANDARD_HA" && length(var.memorystore.locations) == 0 ? (length(data.google_compute_zones.available.names) >= 2 ? [
    data.google_compute_zones.available.names[0],
    data.google_compute_zones.available.names[1]
  ] : [data.google_compute_zones.available.names[0]]) : var.memorystore.locations
  redis_configs      = var.memorystore.redis_configs
  persistence_config = var.memorystore.persistence_config
  maintenance_policy = var.memorystore.maintenance_policy
  redis_version      = var.memorystore.redis_version
  #reserved_ip_range       = var.memorystore.reserved_ip_range
  tier                    = var.memorystore.tier
  transit_encryption_mode = var.memorystore.transit_encryption_mode
  replica_count           = var.memorystore.replica_count
  read_replicas_mode      = var.memorystore.read_replicas_mode
  customer_managed_key    = coalesce(var.memorystore.customer_managed_key, local.kms_key_id)
  depends_on              = [module.psa]
}

resource "kubernetes_secret" "memorystore" {
  count = length(module.memorystore) > 0 ? 1 : 0
  metadata {
    name      = "redis"
    namespace = local.namespace
  }
  data = {
    "chain.pem" = one(module.memorystore[0].server_ca_certs[*].cert)
    username    = ""
    password    = module.memorystore[0].auth_string
    host        = module.memorystore[0].host
    port        = module.memorystore[0].port
    url         = module.memorystore[0].url
  }
}

# Service account for pods
module "control_plane_service_account" {
  source               = "./generated/infra-modules/service-account/gcp"
  name                 = "${local.prefix}-control-plane-sa"
  kubernetes_namespace = local.namespace
  roles                = ["roles/pubsub.editor"]
}

module "compute_plane_service_account" {
  source               = "./generated/infra-modules/service-account/gcp"
  name                 = "${local.prefix}-compute-plane-sa"
  kubernetes_namespace = local.namespace
  roles                = ["roles/pubsub.editor"]
}

# HMac for buckets
resource "google_storage_hmac_key" "cloud_storage" {
  service_account_email = module.gke.service_account
}

# Give Storage Admin role to GKE service account
resource "google_project_iam_member" "allow_gcs_access" {
  project = data.google_client_config.current.project
  role    = "roles/storage.admin"
  member  = "serviceAccount:${module.gke.service_account}"
}

# Shared storage for compute-plane
module "gcs_fs" {
  source               = "./generated/infra-modules/storage/gcp/gcs"
  name                 = "${local.prefix}-gcsfs"
  namespace            = local.namespace
  location             = local.region
  default_kms_key_name = local.kms_key_id
  force_destroy        = true
  labels               = local.labels
}

# Shared storage
resource "kubernetes_secret" "shared_storage" {
  metadata {
    name      = "shared-storage"
    namespace = local.namespace
  }
  data = {
    file_storage_type     = "S3"
    service_url           = "https://storage.googleapis.com"
    access_key_id         = google_storage_hmac_key.cloud_storage.access_id
    secret_access_key     = google_storage_hmac_key.cloud_storage.secret
    name                  = module.gcs_fs.name
    must_force_path_style = false
    use_chunk_encoding    = false
    use_check_sum         = false
  }
}

# GCP bucket as object storage
module "gcs_os" {
  count                = var.gcs_os != null ? 1 : 0
  source               = "./generated/infra-modules/storage/gcp/gcs"
  name                 = "${local.prefix}-gcsos"
  namespace            = local.namespace
  location             = local.region
  default_kms_key_name = local.kms_key_id
  force_destroy        = true
  labels               = local.labels
}

resource "kubernetes_secret" "gcs" {
  count = length(module.gcs_os) > 0 ? 1 : 0
  metadata {
    name      = "s3"
    namespace = local.namespace
  }
  data = {
    username              = google_storage_hmac_key.cloud_storage.access_id
    password              = google_storage_hmac_key.cloud_storage.secret
    url                   = "https://storage.googleapis.com"
    bucket_name           = module.gcs_os[0].name
    must_force_path_style = false
    use_chunk_encoding    = false
    use_check_sum         = false
  }
}

# Pub/Sub
module "pubsub" {
  count      = var.activemq == null ? 1 : 0
  source     = "./generated/infra-modules/storage/gcp/pubsub"
  project_id = data.google_client_config.current.project
  kms_key_id = data.google_kms_crypto_key.kms.id
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
