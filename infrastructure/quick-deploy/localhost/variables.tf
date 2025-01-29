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

# Prefix
variable "prefix" {
  description = "Prefix used to name all the resources"
  type        = string
  default     = null # random
}

# Kubernetes namespace
variable "namespace" {
  description = "Kubernetes namespace for ArmoniK"
  type        = string
  default     = "armonik"
}

# Logging level
variable "logging_level" {
  description = "Logging level in ArmoniK"
  type        = string
  default     = "Information"
}

# Metrics Server
variable "metrics_server" {
  description = "Parameters of the metrics server"
  type = object({
    namespace          = optional(string, "kube-system"),
    image_name         = optional(string, "registry.k8s.io/metrics-server/metrics-server"),
    image_tag          = optional(string),
    image_pull_secrets = optional(string, ""),
    node_selector      = optional(any, {}),
    args = optional(list(string), [
      "--cert-dir=/tmp",
      "--kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname",
      "--kubelet-use-node-status-port",
      "--metric-resolution=15s",
      "--kubelet-insecure-tls"
    ]),
    host_network          = optional(bool, false),
    helm_chart_repository = optional(string)
    helm_chart_version    = optional(string, "3.8.3")
  })
  default = null
}

# Keda
variable "keda" {
  description = "Keda configuration"
  type = object({
    namespace                       = optional(string, "default")
    keda_image_name                 = optional(string, "ghcr.io/kedacore/keda"),
    keda_image_tag                  = optional(string),
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

# Shared storage
variable "shared_storage" {
  description = "Shared storage infos"
  type = object({
    host_path         = string
    file_storage_type = optional(string, "HostPath")
    file_server_ip    = optional(string, "")
  })
  default = null
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

# Parameters for RabbitMQ
variable "rabbitmq" {
  description = "Parameters of RabbitMQ"
  type = object({
    image                 = optional(string, "bitnami/rabbitmq")
    tag                   = optional(string)
    helm_chart_repository = optional(string)
    helm_chart_version    = optional(string)
    service_type          = optional(string, "ClusterIP")
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
    image_pull_secrets    = optional(string, "")
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

# Parameters for Redis
variable "redis" {
  description = "Parameters of Redis"
  type = object({
    image_name         = optional(string, "redis")
    image_tag          = optional(string)
    node_selector      = optional(any, {})
    image_pull_secrets = optional(string, "")
    max_memory         = optional(string, "8000gb")
    max_memory_samples = optional(number)
  })
  default = null
}

#parameters for Nfs
variable "nfs" {
  type = object({
    image    = optional(string, "registry.k8s.io/sig-storage/nfs-subdir-external-provisioner")
    tag      = optional(string)
    server   = optional(string)
    path     = optional(string)
    pvc_name = optional(string, "nfsvolume")
  })
  default = null
}

# Parameters for Minio
variable "minio" {
  description = "Parameters of Minio"
  type = object({
    image_name         = optional(string, "minio/minio")
    image_tag          = optional(string)
    node_selector      = optional(any, {})
    image_pull_secrets = optional(string, "")
    default_bucket     = optional(string, "minio-bucket")
    host               = optional(string, "minio")
  })
  default = null
}

# Parameters for Minio file storage
variable "minio_s3_fs" {
  description = "Parameters of Minio"
  type = object({
    image_name         = optional(string, "minio/minio")
    image_tag          = optional(string)
    node_selector      = optional(any, {})
    image_pull_secrets = optional(string, "")
    default_bucket     = optional(string, "minio-bucket")
    host               = optional(string, "minio-s3-fs")
  })
  default = null
}

variable "seq" {
  description = "Seq configuration"
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
  default = {}
}

variable "grafana" {
  description = "Grafana configuration"
  type = object({
    image_name     = optional(string, "grafana/grafana")
    image_tag      = optional(string)
    port           = optional(number, 3000)
    pull_secrets   = optional(string, "")
    service_type   = optional(string, "ClusterIP")
    node_selector  = optional(any, {})
    authentication = optional(bool, false)
  })
  default = {}
}

variable "node_exporter" {
  description = "Node exporter configuration"
  type = object({
    image_name    = optional(string, "prom/node-exporter")
    image_tag     = optional(string)
    pull_secrets  = optional(string, "")
    service_type  = optional(string, "ClusterIP")
    node_selector = optional(any, {})
  })
  default = {}
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
  description = "Partition metrics exporter configuration"
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
    parser                             = optional(string, "docker")
    fluent_bit_state_hostpath          = optional(string, "/var/fluent-bit/state")
    var_lib_docker_containers_hostpath = optional(string, "/var/lib/docker/containers")
    run_log_journal_hostpath           = optional(string, "/run/log/journal")
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
    name                 = optional(string, "control-plane")
    service_type         = optional(string, "ClusterIP")
    replicas             = optional(number, 1)
    image                = optional(string, "dockerhubaneo/armonik_control")
    tag                  = optional(string)
    image_pull_policy    = optional(string, "IfNotPresent")
    port                 = optional(number, 5001)
    service_account_name = optional(string, "")
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
    service_account_name             = optional(string, "")
    socket_type                      = optional(string, "unixdomainsocket")
    polling_agent = object({
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
      conf = optional(any, [])
    })
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
      conf = optional(any, [])
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
  description = "Parameters of the ingress controller"
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

variable "image_tags" {
  description = "Tags of images used"
  type        = map(string)
}

variable "helm_charts" {
  description = "Versions of helm charts repositories"
  type = map(object({
    repository = string
    version    = string
  }))
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
