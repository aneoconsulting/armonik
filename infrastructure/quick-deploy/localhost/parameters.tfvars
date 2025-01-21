# Logging level
logging_level = "Information"

# Uncomment to deploy metrics server
#metrics_server = {}

# Object storage
# Uncomment either the `redis`, the `minio`or the `nfs` parameter
redis = {}
#minio = {}
# nfs = {
#   server     = "172.30.37.125"
#   path       = "/srv/files"
# }
# Uncomment this to have minio S3 enabled instead of hostpath shared_storage
#minio_s3_fs = {} # Shared storage

# Queue
# Uncomment either the `activemq` or the `rabbitmq` parameter
activemq = {
  activemq_opts_memory = "-Xms1g -Xmx3g"
}

#rabbitmq = {}

/*parition_metrics_exporter = {
  extra_conf = {
    env = {
      MongoDB__AllowInsecureTls              = true
      Serilog__MinimumLevel                  = "Information"
      MongoDB__TableStorage__PollingDelayMin = "00:00:01"
      MongoDB__TableStorage__PollingDelayMax = "00:00:10"
      MongoDB__DataRetention                 = "1.00:00:00"
    }
  }
}*/

# Parameters of control plane
control_plane = {
  limits = {
    cpu    = "1000m"
    memory = "2048Mi"
  }
  requests = {
    cpu    = "50m"
    memory = "50Mi"
  }
  default_partition = "default"
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
  # Default partition that uses the C# extension for the worker
  default = {
    # number of replicas for each deployment of compute plane
    replicas = 0
    # ArmoniK polling agent
    polling_agent = {
      limits = {
        cpu    = "2000m"
        memory = "2048Mi"
      }
      requests = {
        cpu    = "50m"
        memory = "50Mi"
      }
    }
    # ArmoniK workers
    worker = [
      {
        image = "dockerhubaneo/armonik_worker_dll"
        limits = {
          cpu    = "1000m"
          memory = "1024Mi"
        }
        requests = {
          cpu    = "50m"
          memory = "50Mi"
        }
      }
    ]
    hpa = {
      type              = "prometheus"
      polling_interval  = 15
      cooldown_period   = 300
      min_replica_count = 0
      max_replica_count = 5
      behavior = {
        restore_to_original_replica_count = true
        stabilization_window_seconds      = 300
        type                              = "Percent"
        value                             = 100
        period_seconds                    = 15
      }
      triggers = [
        {
          type      = "prometheus"
          threshold = 2
        },
      ]
    }
  },
  # Partition for the stream worker
  stream = {
    # number of replicas for each deployment of compute plane
    replicas = 0
    # ArmoniK polling agent
    polling_agent = {
      limits = {
        cpu    = "2000m"
        memory = "2048Mi"
      }
      requests = {
        cpu    = "50m"
        memory = "50Mi"
      }
    }
    # ArmoniK workers
    worker = [
      {
        image = "dockerhubaneo/armonik_core_stream_test_worker"
        limits = {
          cpu    = "1000m"
          memory = "1024Mi"
        }
        requests = {
          cpu    = "50m"
          memory = "50Mi"
        }
      }
    ]
    hpa = {
      type              = "prometheus"
      polling_interval  = 15
      cooldown_period   = 300
      min_replica_count = 0
      max_replica_count = 5
      behavior = {
        restore_to_original_replica_count = true
        stabilization_window_seconds      = 300
        type                              = "Percent"
        value                             = 100
        period_seconds                    = 15
      }
      triggers = [
        {
          type      = "prometheus"
          threshold = 2
        },
      ]
    }
  },
  # Partition for the htcmock worker
  htcmock = {
    # number of replicas for each deployment of compute plane
    replicas = 0
    # Socket type used by agent and worker to communicate
    socket_type = "tcp"
    # ArmoniK polling agent
    polling_agent = {
      limits = {
        cpu    = "2000m"
        memory = "2048Mi"
      }
      requests = {
        cpu    = "50m"
        memory = "50Mi"
      }
    }
    # ArmoniK workers
    worker = [
      {
        image = "dockerhubaneo/armonik_core_htcmock_test_worker"
        limits = {
          cpu    = "1000m"
          memory = "1024Mi"
        }
        requests = {
          cpu    = "50m"
          memory = "50Mi"
        }
      }
    ]
    hpa = {
      type              = "prometheus"
      polling_interval  = 15
      cooldown_period   = 300
      min_replica_count = 0
      max_replica_count = 5
      behavior = {
        restore_to_original_replica_count = true
        stabilization_window_seconds      = 300
        type                              = "Percent"
        value                             = 100
        period_seconds                    = 15
      }
      triggers = [
        {
          type      = "prometheus"
          threshold = 2
        },
      ]
    }
  },
  # Partition for the bench worker
  bench = {
    # number of replicas for each deployment of compute plane
    replicas = 0
    # ArmoniK polling agent
    polling_agent = {
      limits = {
        cpu    = "2000m"
        memory = "2048Mi"
      }
      requests = {
        cpu    = "50m"
        memory = "50Mi"
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
          cpu    = "50m"
          memory = "50Mi"
        }
      }
    ]
    hpa = {
      type              = "prometheus"
      polling_interval  = 15
      cooldown_period   = 300
      min_replica_count = 0
      max_replica_count = 5
      behavior = {
        restore_to_original_replica_count = true
        stabilization_window_seconds      = 300
        type                              = "Percent"
        value                             = 100
        period_seconds                    = 15
      }
      triggers = [
        {
          type      = "prometheus"
          threshold = 2
        },
      ]
    }
  },
}

# Deploy ingress
# PS: to not deploy ingress put: "ingress=null"
ingress = {
  tls                  = false
  mtls                 = false
  generate_client_cert = false
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
      MongoDB__TableStorage__PollingDelayMin     = "00:00:01"
      MongoDB__TableStorage__PollingDelayMax     = "00:00:10"
      MongoDB__AllowInsecureTls                  = true
      MongoDB__TableStorage__PollingDelay        = "00:00:01"
      MongoDB__DataRetention                     = "1.00:00:00"
      Redis__Timeout                             = 30000
      Redis__SslHost                             = "127.0.0.1"
      Redis__TtlTimeSpan                         = "1.00:00:00"
      Submitter__DeletePayload                   = true
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
  name        = "local-dev"
  version     = "0.0.0"
  description = "Local development environment"
  color       = "blue"
}

static = {
  gui_configuration = {}
}

mongodb = {
  # Uncomment to define custom resources for MongoDB pods, comment for default values
  # mongodb_resources = {
  #   limits = {
  #     "cpu"               = 2
  #     "memory"            = "2Gi"
  #     "ephemeral-storage" = "10Gi"
  #   }
  #   requests = {
  #     "cpu"               = "500m"
  #     "memory"            = "500Mi"
  #     "ephemeral-storage" = "1Gi"
  #   }
  # }

  # Uncomment to define custom resources for MongoDB arbiter pods, comment for default values
  # arbiter_resources = {
  #   limits = {
  #     "cpu"               = "400m"
  #     "memory"            = "4Gi"
  #     "ephemeral-storage" = "1Gi"
  #   }
  #   requests = {
  #     "cpu"               = "100m"
  #     "memory"            = "2Gi"
  #     "ephemeral-storage" = "500Mi"
  #   }
  # }

  # Uncomment the line below to enable persistence, comment to disable
  # persistent_volume = {}
}

# Nullify to disable sharding
# mongodb_sharding = {}
