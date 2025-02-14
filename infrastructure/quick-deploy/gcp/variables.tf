# Prefix
variable "prefix" {
  description = "Prefix used to name all the resources"
  type        = string
  default     = null # random
}

# GCP region
variable "region" {
  description = "The GCP region used to deploy all resources"
  type        = string
  default     = "europe-west1"
}

# GCP project
variable "project" {
  description = "GCP project name"
  type        = string
}

# Map of labels
variable "labels" {
  description = "Labels for GCP resources"
  type        = map(string)
  default     = {}
}

# KMS key name to encrypt/decrypt resources
variable "kms" {
  description = "Cloud KMS used to encrypt/decrypt resources."
  type = object({
    key_ring   = string
    crypto_key = string
  })
}

# VPC and subnets for resources
variable "subnets" {
  description = "A map of subnets inside the VPC. Each subnet object has a CIDR block, a region, and a boolean set to true if the subnet is public, or false if the subnet is private"
  type = map(object({
    cidr_block    = optional(string)
    public_access = optional(bool)
  }))
  default = null
}

# GCP Kubernetes cluster
variable "gke" {
  description = "GKE cluster configuration"
  type = object({
    subnet = optional(object({
      name                = optional(string, "gke-subnet")
      nodes_cidr_block    = optional(string, "10.43.0.0/16")
      pods_cidr_block     = optional(string, "172.16.0.0/16")
      services_cidr_block = optional(string, "172.17.17.0/24")
    }), {})
    namespace                = optional(string, "armonik")
    generate_kubeconfig      = optional(bool, true)
    kubeconfig_file          = optional(string, "generated/kubeconfig")
    enable_public_gke_access = optional(bool, true)
    enable_gke_autopilot     = optional(bool, false)
    regional                 = optional(bool, true)
    zones                    = optional(list(string), [])
    node_pools_labels        = optional(map(map(string)), null)
    node_pools_taints        = optional(map(list(object({ key = string, value = string, effect = string }))), null)
    node_pools               = optional(list(map(any)), null)
  })
  default = {}
}

# Keda
variable "keda" {
  description = "Keda configuration"
  type = object({
    namespace                       = optional(string, "default")
    image_name                      = optional(string, "ghcr.io/kedacore/keda"),
    image_tag                       = optional(string),
    apiserver_image_name            = optional(string, "ghcr.io/kedacore/keda-metrics-apiserver"),
    apiserver_image_tag             = optional(string),
    pull_secrets                    = optional(string, ""),
    node_selector                   = optional(any, {})
    metrics_server_dns_policy       = optional(string, "ClusterFirst")
    metrics_server_use_host_network = optional(bool, false)
    helm_chart_repository           = optional(string)
    helm_chart_version              = optional(string)
  })
  default = {}
}

# Chaos Mesh
variable "chaos_mesh" {
  description = "Chaos Mesh configuration"
  type = object({
    namespace                 = optional(string, "chaos-mesh")
    chaosmesh_image_name      = optional(string, "ghcr.io/chaos-mesh/chaos-mesh"),
    chaosmesh_image_tag       = optional(string),
    chaosdaemon_image_name    = optional(string, "ghcr.io/chaos-mesh/chaos-daemon"),
    chaosdaemon_image_tag     = optional(string),
    chaosdashboard_image_name = optional(string, "ghcr.io/chaos-mesh/chaos-dashboard"),
    chaosdashboard_image_tag  = optional(string),
    helm_chart_repository     = optional(string)
    helm_chart_version        = optional(string)
    service_type              = optional(string, "LoadBalancer")
    node_selector             = optional(any, {})
    endpoint_url              = optional(string)
  })
  default = null
}

# Parameters for MongoDB
variable "mongodb" {
  description = "Parameters of MongoDB"
  type = object({
    image_name            = optional(string)
    image_tag             = optional(string)
    node_selector         = optional(any, {})
    pull_secrets          = optional(string, "")
    replicas              = optional(number, 1)
    helm_chart_repository = optional(string)
    helm_chart_version    = optional(string)

    mongodb_resources = optional(object({
      limits   = optional(map(string))
      requests = optional(map(string))
    }))

    arbiter_resources = optional(object({
      limits   = optional(map(string))
      requests = optional(map(string))
    }))

    persistent_volume = optional(object({
      storage_provisioner = optional(string)
      volume_binding_mode = optional(string, "Immediate")
      reclaim_policy      = optional(string, "Delete")
      parameters          = optional(map(string), {})
      #Resources for PVC
      resources = optional(object({
        limits = optional(object({
          storage = string
        }))
        requests = optional(object({
          storage = string
        }))
      }))
    }))
  })
  default = {}
}

variable "mongodb_sharding" {
  description = "Configuration for MongoDB sharding, if it is null no sharding will be present"
  type = object({
    shards = optional(object({
      quantity      = optional(number)
      replicas      = optional(number)
      node_selector = optional(map(string))
      resources = optional(object({
        limits   = optional(map(string))
        requests = optional(map(string))
      }))
      labels = optional(map(string))
    }))

    arbiter = optional(object({
      node_selector = optional(map(string), {})
      resources = optional(object({
        limits   = optional(map(string))
        requests = optional(map(string))
      }))
      labels = optional(map(string))
    }))

    router = optional(object({
      replicas      = optional(number)
      node_selector = optional(map(string))
      resources = optional(object({
        limits   = optional(map(string))
        requests = optional(map(string))
      }))
      labels = optional(map(string))
    }))

    configsvr = optional(object({
      replicas      = optional(number)
      node_selector = optional(map(string))
      resources = optional(object({
        limits   = optional(map(string))
        requests = optional(map(string))
      }))
      labels = optional(map(string))
    }))
  })
  default = null
}

# GCP Memorystore for Redis
variable "memorystore" {
  description = "Configuration of GCP Memorystore for Redis"
  type = object({
    memory_size_gb     = number
    auth_enabled       = optional(bool, true)
    connect_mode       = optional(string, "DIRECT_PEERING") # or PRIVATE_SERVICE_ACCESS
    display_name       = optional(string, "armonik-redis")
    locations          = optional(list(string), [])
    redis_configs      = optional(map(string), null)
    reserved_ip_range  = optional(string, null)
    persistence_config = optional(map(string), null)
    maintenance_policy = optional(object({
      day        = optional(string),
      start_time = optional(map(string))
    }), null)
    redis_version           = string
    tier                    = optional(string, "BASIC")
    transit_encryption_mode = optional(string, "SERVER_AUTHENTICATION")
    replica_count           = optional(number, 1)
    read_replicas_mode      = optional(string, "READ_REPLICAS_DISABLED")
    secondary_ip_range      = optional(string, "")
    customer_managed_key    = optional(string, null)
  })
  default = null
}

# GCS for object storage of payloads
variable "gcs_os" {
  description = "Use GCS as object storage"
  type        = any
  default     = null
}

# ArmoniK docker images
variable "armonik_images" {
  description = "Image names of all the ArmoniK components"
  type = object({
    infra         = set(string)
    infra_plugins = set(string)
    core          = set(string)
    api           = set(string)
    gui           = set(string)
    extcsharp     = set(string)
    samples       = set(string)
  })
}

# Versions of the ArmoniK docker images
variable "armonik_versions" {
  description = "Versions of all the ArmoniK components"
  type = object({
    infra         = string
    infra_plugins = string
    core          = string
    api           = string
    gui           = string
    extcsharp     = string
    samples       = string
  })
}

variable "upload_images" {
  description = "Whether the images are uploaded to the Artifact Registry or not"
  type        = bool
  default     = true
}

variable "seq" {
  description = "Seq configuration (nullable)"
  type = object({
    image_name        = optional(string, "datalust/seq")
    image_tag         = optional(string)
    port              = optional(number, 8080)
    pull_secrets      = optional(string, "")
    service_type      = optional(string, "ClusterIP")
    node_selector     = optional(any, {})
    system_ram_target = optional(number, 0.2)
    authentication    = optional(bool, false)
    cli_image_name    = optional(string, "datalust/seqcli")
    cli_image_tag     = optional(string)
    cli_pull_secrets  = optional(string, "")
    retention_in_days = optional(string, "2d")
  })
  default = null
}

variable "grafana" {
  description = "Grafana configuration (nullable)"
  type = object({
    image_name     = optional(string, "grafana/grafana")
    image_tag      = optional(string)
    port           = optional(number, 3000)
    pull_secrets   = optional(string, "")
    service_type   = optional(string, "ClusterIP")
    node_selector  = optional(any, {})
    authentication = optional(bool, false)
  })
  default = null
}

variable "node_exporter" {
  description = "Node exporter configuration (nullable)"
  type = object({
    image_name    = optional(string, "prom/node-exporter")
    image_tag     = optional(string)
    pull_secrets  = optional(string, "")
    service_type  = optional(string, "ClusterIP")
    node_selector = optional(any, {})
  })
  default = null
}

variable "prometheus" {
  description = "Prometheus configuration"
  type = object({
    image_name    = optional(string, "prom/prometheus")
    image_tag     = optional(string)
    pull_secrets  = optional(string, "")
    service_type  = optional(string, "ClusterIP")
    node_selector = optional(any, {})
  })
  default = {}
}

variable "metrics_exporter" {
  description = "Metrics exporter configuration"
  type = object({
    image_name    = optional(string, "dockerhubaneo/armonik_control_metrics")
    image_tag     = optional(string)
    pull_secrets  = optional(string, "")
    service_type  = optional(string, "ClusterIP")
    node_selector = optional(any, {})
    extra_conf    = optional(map(string), {})
  })
  default = {}
}

variable "partition_metrics_exporter" {
  description = "Partition metrics exporter configuration (nullable)"
  type = object({
    image_name    = optional(string, "dockerhubaneo/armonik_control_partition_metrics")
    image_tag     = optional(string)
    pull_secrets  = optional(string, "")
    service_type  = optional(string, "ClusterIP")
    node_selector = optional(any, {})
    extra_conf    = optional(map(string), {})
  })
  default = null
}

variable "fluent_bit" {
  description = "Fluent bit configuration"
  type = object({
    image_name                         = optional(string, "fluent/fluent-bit")
    image_tag                          = optional(string)
    pull_secrets                       = optional(string, "")
    is_daemonset                       = optional(bool, true)
    http_port                          = optional(number, 2020)
    read_from_head                     = optional(bool, true)
    node_selector                      = optional(any, {})
    parser                             = optional(string, "cri")
    fluent_bit_state_hostpath          = optional(string, "/var/log/fluent-bit/state")
    var_lib_docker_containers_hostpath = optional(string, "/var/log/lib/docker/containers")
    run_log_journal_hostpath           = optional(string, "/var/log/run/log/journal")
  })
  default = {}
}

# Extra configuration
variable "configurations" {
  description = ""
  type = object({
    core    = optional(any, [])
    control = optional(any, [])
    compute = optional(any, [])
    worker  = optional(any, [])
    polling = optional(any, [])
    log     = optional(any, [])
    metrics = optional(any, [])
    jobs    = optional(any, [])
  })
}

# Job to insert partitions in the database
variable "job_partitions_in_database" {
  description = "Job to insert partitions IDs in the database"
  type = object({
    name               = optional(string, "job-partitions-in-database")
    image              = optional(string, "rtsp/mongosh")
    tag                = optional(string)
    image_pull_policy  = optional(string, "IfNotPresent")
    image_pull_secrets = optional(string, "")
    node_selector      = optional(any, {})
    annotations        = optional(any, {})
  })
  default = {}
}

# Parameters of control plane
variable "control_plane" {
  description = "Parameters of the control plane"
  type = object({
    name              = optional(string, "control-plane")
    service_type      = optional(string, "ClusterIP")
    replicas          = optional(number, 2)
    image             = optional(string, "dockerhubaneo/armonik_control")
    tag               = optional(string)
    image_pull_policy = optional(string, "IfNotPresent")
    port              = optional(number, 5001)
    limits = optional(object({
      cpu    = optional(string)
      memory = optional(string)
    }))
    requests = optional(object({
      cpu    = optional(string)
      memory = optional(string)
    }))
    image_pull_secrets = optional(string, "")
    node_selector      = optional(any, {})
    annotations        = optional(any, {})
    # KEDA scaler
    hpa               = optional(any)
    default_partition = string
  })
}

# Parameters of admin gui
variable "admin_gui" {
  description = "Parameters of the admin GUI"
  type = object({
    name  = optional(string, "admin-app")
    image = optional(string, "dockerhubaneo/armonik_admin_app")
    tag   = optional(string)
    port  = optional(number, 1080)
    limits = optional(object({
      cpu    = optional(string)
      memory = optional(string)
    }))
    requests = optional(object({
      cpu    = optional(string)
      memory = optional(string)
    }))
    service_type       = optional(string, "ClusterIP")
    replicas           = optional(number, 1)
    image_pull_policy  = optional(string, "IfNotPresent")
    image_pull_secrets = optional(string, "")
    node_selector      = optional(any, {})
  })
  default = {}
}

# Parameters of the compute plane
variable "compute_plane" {
  description = "Parameters of the compute plane"
  type = map(object({
    replicas                         = optional(number, 1)
    termination_grace_period_seconds = optional(number, 30)
    image_pull_secrets               = optional(string, "IfNotPresent")
    node_selector                    = optional(any, {})
    annotations                      = optional(any, {})
    polling_agent = optional(object({
      image             = optional(string, "dockerhubaneo/armonik_pollingagent")
      tag               = optional(string)
      image_pull_policy = optional(string, "IfNotPresent")
      limits = optional(object({
        cpu    = optional(string)
        memory = optional(string)
      }))
      requests = optional(object({
        cpu    = optional(string)
        memory = optional(string)
      }))
    }), {})
    worker = list(object({
      name              = optional(string, "worker")
      image             = string
      tag               = optional(string)
      image_pull_policy = optional(string, "IfNotPresent")
      limits = optional(object({
        cpu    = optional(string)
        memory = optional(string)
      }))
      requests = optional(object({
        cpu    = optional(string)
        memory = optional(string)
      }))
    }))
    cache_config = optional(object({
      memory     = optional(bool)
      size_limit = optional(string)
    }), {})
    # KEDA scaler
    hpa = optional(any)
  }))
}

variable "ingress" {
  description = "Parameters of the ingress controller (nullable)"
  type = object({
    name              = optional(string, "ingress")
    service_type      = optional(string, "LoadBalancer")
    replicas          = optional(number, 1)
    image             = optional(string, "nginxinc/nginx-unprivileged")
    tag               = optional(string)
    image_pull_policy = optional(string, "IfNotPresent")
    http_port         = optional(number, 5000)
    grpc_port         = optional(number, 5001)
    limits = optional(object({
      cpu    = optional(string)
      memory = optional(string)
    }))
    requests = optional(object({
      cpu    = optional(string)
      memory = optional(string)
    }))
    image_pull_secrets    = optional(string, "")
    node_selector         = optional(any, {})
    annotations           = optional(any, {})
    tls                   = optional(bool, false)
    mtls                  = optional(bool, false)
    generate_client_cert  = optional(bool, true)
    custom_client_ca_file = optional(string, "")
  })
  default = {}
}

# Authentication behavior
variable "authentication" {
  description = "Authentication behavior"
  type = object({
    name                    = optional(string, "job-authentication-in-database")
    image                   = optional(string, "rtsp/mongosh")
    tag                     = optional(string)
    image_pull_policy       = optional(string, "IfNotPresent")
    image_pull_secrets      = optional(string, "")
    node_selector           = optional(any, {})
    authentication_datafile = optional(string, "")
    require_authentication  = optional(bool, false)
    require_authorization   = optional(bool, false)
  })
  default = {}
}

variable "pod_deletion_cost" {
  description = "Configuration of Pod Deletion Cost updater"
  type = object({
    image               = optional(string, "dockerhubaneo/armonik_pdc_update")
    tag                 = optional(string)
    image_pull_policy   = optional(string, "IfNotPresent")
    image_pull_secrets  = optional(string, "")
    node_selector       = optional(any, {})
    annotations         = optional(any, {})
    name                = optional(string, "pdc-update")
    label_app           = optional(string, "armonik")
    prometheus_url      = optional(string)
    metrics_name        = optional(string)
    period              = optional(number)
    ignore_younger_than = optional(number)
    concurrency         = optional(number)
    granularity         = optional(number)
    extra_conf          = optional(map(string), {})

    limits = optional(object({
      cpu    = optional(string)
      memory = optional(string)
    }))
    requests = optional(object({
      cpu    = optional(string)
      memory = optional(string)
    }))
  })
  default = {}
}

# Versions of Third-party docker images
variable "image_tags" {
  description = "Tags of images used"
  type        = map(string)
}

# Repositories and versions of Helm charts
variable "helm_charts" {
  description = "Versions of helm charts repositories"
  type = map(object({
    repository = string
    version    = string
  }))
}

# Logging level
variable "logging_level" {
  description = "Logging level in ArmoniK"
  type        = string
  default     = "Information"
}

variable "environment_description" {
  description = "Description of the environment"
  type        = any
  default     = null
}

variable "static" {
  description = "json files to be served statically by the ingress"
  type        = any
  default     = {}
}

# Parameters for ActiveMQ
variable "activemq" {
  description = "Parameters of ActiveMQ"
  type = object({
    image_name         = optional(string, "symptoma/activemq")
    image_tag          = optional(string)
    node_selector      = optional(any, {})
    image_pull_secrets = optional(string, "")
    limits = optional(object({
      cpu    = optional(string)
      memory = optional(string)
    }))
    requests = optional(object({
      cpu    = optional(string)
      memory = optional(string)
    }))
    activemq_opts_memory = optional(string, "-Xms1g -Xmx3g")
  })
  default = null
}
