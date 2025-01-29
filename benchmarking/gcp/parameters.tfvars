# GKE
gke = {
  enable_public_gke_access = true
  enable_gke_autopilot     = false
  regional = true
  zones = ["us-central1-a"]
  node_pools_labels = {
    workers = {
      service = "workers"
    }
    metrics = {
      service = "metrics"
    }
    control-plane = {
      service = "control-plane"
    }
    monitoring = {
      service = "monitoring"
    }
    state-database = {
      service = "state-database"
    }
    others = {
      service = "others"
    }
  }
  node_pools_taints = {
    workers = [
      {
        key    = "service"
        value  = "workers"
        effect = "NO_SCHEDULE"
      }
    ]
    metrics = [
      {
        key    = "service"
        value  = "metrics"
        effect = "NO_SCHEDULE"
      }
    ]
    control-plane = [
      {
        key    = "service"
        value  = "control-plane"
        effect = "NO_SCHEDULE"
      }
    ]
    monitoring = [
      {
        key    = "service"
        value  = "monitoring"
        effect = "NO_SCHEDULE"
      }
    ]
    state-database = [
      {
        key    = "service"
        value  = "state-database"
        effect = "NO_SCHEDULE"
      }
    ]
  }
  node_pools = [
    {
      name             = "workers"
      machine_type     = "c3d-highcpu-16"
      image_type       = "COS_CONTAINERD"
      min_cpu_platform = ""
      # or see https://cloud.google.com/compute/docs/instances/specify-min-cpu-platform#availablezones
      autoscaling                 = true
      node_count                  = null # should not be used alongside autoscaling
      max_pods_per_node           = 110
      initial_node_count          = 8
      min_count                   = 8          # per zone. It is null if used alongside total_min_count
      max_count                   = 8       # per zone. It is null if used alongside total_max_count
      total_min_count             = 8          # per NodePool
      total_max_count             = 8       # per NodePool
      location_policy             = "BALANCED" # or ANY
      auto_repair                 = true
      auto_upgrade                = true
      enable_gcfs                 = false
      enable_gvnic                = false
      logging_variant             = "DEFAULT"
      local_ssd_count             = 0
      disk_size_gb                = 100
      disk_type                   = "pd-balanced"
      spot                        = true
      boot_disk_kms_key           = ""
      enable_secure_boot          = false
      enable_integrity_monitoring = true
    },
    {
      name             = "metrics"
      machine_type     = "n2-highcpu-2"
      image_type       = "COS_CONTAINERD"
      min_cpu_platform = ""
      # or see https://cloud.google.com/compute/docs/instances/specify-min-cpu-platform#availablezones
      autoscaling                 = false
      node_count                  = 5 # should not be used alongside autoscaling
      max_pods_per_node           = 20
      initial_node_count          = 1
      min_count                   = 1          # per zone. It is null if used alongside total_min_count
      max_count                   = 5          # per zone. It is null if used alongside total_max_count
      total_min_count             = 1          # per NodePool
      total_max_count             = 5          # per NodePool
      location_policy             = "BALANCED" # or ANY
      auto_repair                 = true
      auto_upgrade                = true
      enable_gcfs                 = false
      enable_gvnic                = false
      logging_variant             = "DEFAULT"
      local_ssd_count             = 0
      disk_size_gb                = 100
      disk_type                   = "pd-balanced"
      spot                        = false
      boot_disk_kms_key           = ""
      enable_secure_boot          = false
      enable_integrity_monitoring = true
    },
    {
      name             = "control-plane"
      machine_type     = "c3d-highcpu-16"
      image_type       = "COS_CONTAINERD"
      min_cpu_platform = ""
      # or see https://cloud.google.com/compute/docs/instances/specify-min-cpu-platform#availablezones
      autoscaling                 = true
      node_count                  = null # should not be used alongside autoscaling
      max_pods_per_node           = 120
      initial_node_count          = 1
      min_count                   = 1          # per zone. It is null if used alongside total_min_count
      max_count                   = 1         # per zone. It is null if used alongside total_max_count
      total_min_count             = 1          # per NodePool
      total_max_count             = 1         # per NodePool
      location_policy             = "BALANCED" # or ANY
      auto_repair                 = true
      auto_upgrade                = true
      enable_gcfs                 = false
      enable_gvnic                = false
      logging_variant             = "DEFAULT"
      local_ssd_count             = 0
      disk_size_gb                = 100
      disk_type                   = "pd-balanced"
      spot                        = false
      boot_disk_kms_key           = ""
      enable_secure_boot          = false
      enable_integrity_monitoring = true
    },
    {
      name             = "monitoring"
      machine_type     = "n2-highcpu-4"
      image_type       = "COS_CONTAINERD"
      min_cpu_platform = ""
      # or see https://cloud.google.com/compute/docs/instances/specify-min-cpu-platform#availablezones
      autoscaling                 = true
      node_count                  = null # should not be used alongside autoscaling
      max_pods_per_node           = 110
      initial_node_count          = 1
      min_count                   = 1          # per zone. It is null if used alongside total_min_count
      max_count                   = 5          # per zone. It is null if used alongside total_max_count
      total_min_count             = 1          # per NodePool
      total_max_count             = 5          # per NodePool
      location_policy             = "BALANCED" # or ANY
      auto_repair                 = true
      auto_upgrade                = true
      enable_gcfs                 = false
      enable_gvnic                = false
      logging_variant             = "DEFAULT"
      local_ssd_count             = 0
      disk_size_gb                = 100
      disk_type                   = "pd-balanced"
      spot                        = false
      boot_disk_kms_key           = ""
      enable_secure_boot          = false
      enable_integrity_monitoring = true
    },
    {
      name             = "state-database"
      machine_type     = "c2d-highcpu-56"
      image_type       = "COS_CONTAINERD"
      min_cpu_platform = ""
      # or see https://cloud.google.com/compute/docs/instances/specify-min-cpu-platform#availablezones
      autoscaling                 = true
      node_count                  = null # should not be used alongside autoscaling
      max_pods_per_node           = 110
      initial_node_count          = 1
      min_count                   = 1          # per zone. It is null if used alongside total_min_count
      max_count                   = 1        # per zone. It is null if used alongside total_max_count
      total_min_count             = 1          # per NodePool
      total_max_count             = 1         # per NodePool
      location_policy             = "BALANCED" # or ANY
      auto_repair                 = true
      auto_upgrade                = true
      enable_gcfs                 = false
      enable_gvnic                = false
      logging_variant             = "DEFAULT"
      local_ssd_count             = 0
      disk_size_gb                = 75
      disk_type                   = "pd-ssd"
      spot                        = false
      boot_disk_kms_key           = ""
      enable_secure_boot          = false
      enable_integrity_monitoring = true
    },
    {
      name             = "others"
      machine_type     = "n2-highcpu-4"
      image_type       = "COS_CONTAINERD"
      min_cpu_platform = ""
      # or see https://cloud.google.com/compute/docs/instances/specify-min-cpu-platform#availablezones
      autoscaling                 = true
      node_count                  = null # should not be used alongside autoscaling
      max_pods_per_node           = 110
      initial_node_count          = 1
      min_count                   = 1          # per zone. It is null if used alongside total_min_count
      max_count                   = 5        # per zone. It is null if used alongside total_max_count
      total_min_count             = 1          # per NodePool
      total_max_count             = 5        # per NodePool
      location_policy             = "BALANCED" # or ANY
      auto_repair                 = true
      auto_upgrade                = true
      enable_gcfs                 = false
      enable_gvnic                = false
      logging_variant             = "DEFAULT"
      local_ssd_count             = 0
      disk_size_gb                = 100
      disk_type                   = "pd-standard"
      spot                        = true
      boot_disk_kms_key           = ""
      enable_secure_boot          = false
      enable_integrity_monitoring = true
    }
  ]
}

kms = {
  key_ring   = "armonik-airflow-bench-us"
  crypto_key = "armonik-airflow-bench-us"
}

# Logging level
logging_level = "Information"

keda = {
  node_selector = { service = "monitoring" }
}

activemq = {
  node_selector = { service = "state-database" }
  limits = {
    cpu    = "4000m"
    memory = "16Gi"
  }
  requests = {
    cpu    = "4000m"
    memory = "16Gi"
  }
  activemq_opts_memory = "-Xms1g -Xmx3g"
}


mongodb = {
  node_selector = { service = "state-database" }
  replicas      = 2
  mongodb_resources = {
    limits = {
      "cpu"               = "23"
      "memory"            = "50Gi"
      "ephemeral-storage" = "20Gi"
    }
    requests = {
      "cpu"               = "10"
      "memory"            = "24Gi"
      "ephemeral-storage" = "8Gi"
    }
  }
}

# Nullify to disable sharding, each nullification of subobject will result in the use of default values 
# mongodb_sharding = {}

# memorystore = {
#  memory_size_gb = 20
#  auth_enabled   = true
#  connect_mode   = "PRIVATE_SERVICE_ACCESS"
#  redis_configs  = {
#    "maxmemory-gb"     = "18"
#    "maxmemory-policy" = "volatile-lru"
#  }
# #  reserved_ip_range       = "10.0.0.0/24"
#  redis_version           = "REDIS_7_0"
#  tier                    = "STANDARD_HA"
#  transit_encryption_mode = "SERVER_AUTHENTICATION"
#  replica_count           = 3
#  read_replicas_mode      = "READ_REPLICAS_ENABLED"
# }
gcs_os = {}

seq = {
  node_selector = { service = "monitoring" }
}

grafana = {
  node_selector = { service = "monitoring" }
}

node_exporter = {
  node_selector = {}
}

prometheus = {
  node_selector = { service = "metrics" }
}

metrics_exporter = {
  node_selector = { service = "metrics" }
}

#parition_metrics_exporter = {
#  node_selector = { service = "metrics" }
#  extra_conf    = {
#  env = {
#    MongoDB__AllowInsecureTls           = true
#    Serilog__MinimumLevel               = "Information"
#    MongoDB__TableStorage__PollingDelayMin     = "00:00:01"
#    MongoDB__TableStorage__PollingDelayMax     = "00:00:10"
#    MongoDB__DataRetention                 = "1.00:00:00" # 1 day retention
#}
#  }
#}

fluent_bit = {
  is_daemonset  = true
  node_selector = {}
}

# Parameters of control plane
control_plane = {
  limits = {
    cpu    = "2000m"
    memory = "4096Mi"
  }
  requests = {
    cpu    = "1000m"
    memory = "2048Mi"
  }
  default_partition = "default"
  replicas=10
  node_selector     = { service = "control-plane" }
}

# Parameters of admin GUI
admin_gui = {
  limits = {
    cpu    = "1000m"
    memory = "1024Mi"
  }
  requests = {
    cpu    = "100m"
    memory = "128Mi"
  }
  node_selector = { service = "monitoring" }
}

# Parameters of the compute plane
compute_plane = {
  # Partition for the bench worker
  bench = {
    node_selector = { service = "workers" }
    # number of replicas for each deployment of compute plane
    replicas = 120
    # ArmoniK polling agent
    polling_agent = {
      limits = {
        cpu    = "1000m"
        memory = "1024Mi"
      }
      requests = {
        cpu    = "500m"
        memory = "256Mi"
      }
    }
    # ArmoniK workers
    worker = [
      {
        image = "dockerhubaneo/armonik_core_bench_test_worker"
        limits = {
          cpu    = "1000m"
          memory = "1024Mi"
        }
        requests = {
          cpu    = "500m"
          memory = "512Mi"
        }
      }
    ]
  }
}

# Deploy ingress
# PS: to not deploy ingress put: "ingress=null"
ingress = {
  tls                  = false
  mtls                 = false
  generate_client_cert = false
  node_selector        = { service = "control-plane" }
}

# Job to insert partitions in the database
job_partitions_in_database = {
  node_selector = { service = "control-plane" }
}
# Authentication behavior
authentication = {
  node_selector = { service = "control-plane" }
}

configurations = {
  core = {
    env = {
      Amqp__AllowHostMismatch                    = true
      Amqp__MaxPriority                          = "10"
      Amqp__MaxRetries                           = "5"
      Amqp__QueueStorage__LockRefreshPeriodicity = "00:00:45"
      Amqp__QueueStorage__PollPeriodicity        = "00:00:10"
      Amqp__QueueStorage__LockRefreshExtension   = "00:02:00"
      MongoDB__TableStorage__PollingDelayMin = "00:00:01"
      MongoDB__TableStorage__PollingDelayMax = "00:00:10"
      MongoDB__TableStorage__PollingDelay    = "00:00:01"
      MongoDB__AllowInsecureTls              = true
      MongoDB__DataRetention                 = "1.00:00:00" # 1 day retention
      Redis__Timeout                         = 3000
      Redis__SslHost                         = ""
      Redis__TtlTimeSpan                     = "1.00:00:00" # 1 day retention
      Submitter__DeletePayload               = true
    }
  }
  control = {
    env = {
      Submitter__MaxErrorAllowed = 50
    }
  }
  worker = {
    env = {
      target_zip_path = "/tmp"
    }
  }
  jobs = { env = { MongoDB__DataRetention = "1.00:00:00" } }
}

environment_description = {
  name        = "gcp-dev"
  version     = "0.0.0"
  description = "GCP environment"
  color       = "#80ff80"
}

upload_images = false