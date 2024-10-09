# Tags
tags = {
  "name"             = ""
  "env"              = ""
  "entity"           = ""
  "bu"               = ""
  "owner"            = ""
  "application code" = ""
  "project code"     = ""
  "cost center"      = ""
  "Support Contact"  = ""
  "origin"           = "terraform"
  "unit of measure"  = ""
  "epic"             = ""
  "functional block" = ""
  "hostname"         = ""
  "interruptible"    = ""
  "tostop"           = ""
  "tostart"          = ""
  "branch"           = ""
  "gridserver"       = ""
  "it division"      = ""
  "Confidentiality"  = ""
  "csp"              = "aws"
  "grafanaserver"    = ""
  "Terraform"        = "true"
  "DST_Update"       = ""
}

vpc = {
  enable_private_subnet = false
}

# AWS EKS
eks = {
  cluster_version                = "1.25"
  node_selector                  = { service = "monitoring" }
  cluster_endpoint_public_access = true
  cluster_addons = {
    vpc-cni = {
      most_recent = true
    }
  }
}

# List of EKS managed node groups
eks_managed_node_groups = {
  # Default node group for workers of ArmoniK
  workers = {
    name                        = "workers"
    launch_template_description = "Node group for ArmoniK Compute-plane pods"
    ami_type                    = "AL2_x86_64"
    instance_types              = ["c5.large"]
    capacity_type               = "SPOT"
    min_size                    = 0
    desired_size                = 0
    max_size                    = 1000
    labels = {
      service                        = "workers"
      "node.kubernetes.io/lifecycle" = "spot"
    }
    taints = {
      dedicated = {
        key    = "service"
        value  = "workers"
        effect = "NO_SCHEDULE"
      }
    }
    iam_role_use_name_prefix = false
    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
  }
  /*
  # Node group for workers of ArmoniK on the GPU
  gpu_workers = {
    name                        = "gpu_workers"
    launch_template_description = "Node group for ArmoniK Compute-plane pods which run on the GPU"
    ami_type                    = "BOTTLEROCKET_x86_64_NVIDIA"
    instance_types              = ["g4dn.xlarge"]
    capacity_type               = "SPOT"
    min_size                    = 0
    desired_size                = 0
    max_size                    = 1000
    labels = {
      service                        = "gpu_workers"
      "node.kubernetes.io/lifecycle" = "spot"
    }
    taints = {
      dedicated = {
        key    = "service"
        value  = "gpu_workers"
        effect = "NO_SCHEDULE"
      }
    }
    iam_role_use_name_prefix = false
    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
  }
  */
  # Node group for metrics: Metrics exporter and Prometheus
  metrics = {
    name                        = "metrics"
    launch_template_description = "Node group for metrics: Metrics exporter and Prometheus"
    ami_type                    = "AL2_x86_64"
    instance_types              = ["c5.large"]
    capacity_type               = "ON_DEMAND"
    min_size                    = 1
    desired_size                = 1
    max_size                    = 5
    labels = {
      service                        = "metrics"
      "node.kubernetes.io/lifecycle" = "ondemand"
    }
    taints = {
      dedicated = {
        key    = "service"
        value  = "metrics"
        effect = "NO_SCHEDULE"
      }
    }
    iam_role_use_name_prefix = false
    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
  }
  # Node group for ArmoniK control-plane: control-plane and Ingress
  control_plane = {
    name                        = "control-plane"
    launch_template_description = "Node group for ArmoniK Control-plane and Ingress"
    ami_type                    = "AL2_x86_64"
    instance_types              = ["c5.large"]
    capacity_type               = "ON_DEMAND"
    min_size                    = 1
    desired_size                = 1
    max_size                    = 10
    labels = {
      service                        = "control-plane"
      "node.kubernetes.io/lifecycle" = "ondemand"
    }
    taints = {
      dedicated = {
        key    = "service"
        value  = "control-plane"
        effect = "NO_SCHEDULE"
      }
    }
    iam_role_use_name_prefix = false
    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
  }
  # Node group for monitoring: metrics server, keda, seq, grafana, cluster-autoscaler, coreDNS, termination handler
  monitoring = {
    name                        = "monitoring"
    launch_template_description = "Node group for monitoring"
    ami_type                    = "AL2_x86_64"
    instance_types              = ["c5.large"]
    capacity_type               = "ON_DEMAND"
    min_size                    = 1
    desired_size                = 1
    max_size                    = 5
    labels = {
      service                        = "monitoring"
      "node.kubernetes.io/lifecycle" = "ondemand"
    }
    taints = {
      dedicated = {
        key    = "service"
        value  = "monitoring"
        effect = "NO_SCHEDULE"
      }
    }
    iam_role_use_name_prefix = false
    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
  }
  # Node group for data-plane
  # state_database, inner_storage, task_queue
  state_database = {
    name                        = "mongodb"
    launch_template_description = "Node group for MongoDB"
    ami_type                    = "AL2_x86_64"
    instance_types              = ["c5.2xlarge"]
    use_custom_launch_template  = true
    block_device_mappings = {
      xvda = {
        device_name = "/dev/xvda"
        ebs = {
          volume_size           = 75
          volume_type           = "gp3"
          iops                  = 3000
          throughput            = 150
          encrypted             = null
          kms_key_id            = null
          delete_on_termination = true
        }
      }
    }
    capacity_type = "ON_DEMAND"
    min_size      = 1
    desired_size  = 1
    max_size      = 10
    labels = {
      service                        = "state-database"
      "node.kubernetes.io/lifecycle" = "ondemand"
    }
    taints = {
      dedicated = {
        key    = "service"
        value  = "state-database"
        effect = "NO_SCHEDULE"
      }
    }
    iam_role_use_name_prefix = false
    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
  }
  # Node group for windows
  windows = {
    name                        = "windows"
    launch_template_description = "Node group for ArmoniK windows based pods"
    ami_type                    = "WINDOWS_CORE_2022_x86_64"
    instance_types              = ["c5.large"]
    capacity_type               = "ON_DEMAND"
    min_size                    = 1
    desired_size                = 1
    max_size                    = 10
    labels = {
      service                        = "windows"
      "node.kubernetes.io/lifecycle" = "ondemand"
    }
    taints = {
      dedicated = {
        key    = "service"
        value  = "windows"
        effect = "NO_SCHEDULE"
      }
    }
    iam_role_use_name_prefix = false
    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore   = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      AmazonEKSClusterPolicy         = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
      AmazonEKSVPCResourceController = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"

    }
  }
}

# List of self managed node groups
self_managed_node_groups = {
  others = {
    name                        = "others"
    launch_template_description = "Node group for others"
    instance_type               = "c5.large"
    min_size                    = 1
    desired_size                = 1
    max_size                    = 5
    force_delete                = true
    force_delete_warm_pool      = true
    instance_market_options = {
      market_type = "spot"
    }
    bootstrap_extra_args     = "--kubelet-extra-args '--node-labels=node.kubernetes.io/lifecycle=spot'"
    iam_role_use_name_prefix = false
    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
  }
  others_mixed = {
    name                        = "others-mixed"
    launch_template_description = "Mixed On demand and SPOT instances for other pods"
    min_size                    = 0
    desired_size                = 0
    max_size                    = 5
    use_mixed_instances_policy  = true
    mixed_instances_policy = {
      on_demand_allocation_strategy            = "lowest-price"
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 20 # 20% On-Demand Instances, 80% Spot Instances
      spot_allocation_strategy                 = "price-capacity-optimized"
      spot_instance_pools                      = null
      spot_max_price                           = null
    }
    override = [
      {
        instance_type     = "c5.4xlarge"
        weighted_capacity = "1"
      },
      {
        instance_type     = "c5.2xlarge"
        weighted_capacity = "2"
      },
    ]
    iam_role_use_name_prefix = false
    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
  }

}

# List of fargate profiles
fargate_profiles = {}

metrics_server = {
  node_selector = { service = "monitoring" }
}

keda = {
  node_selector = { service = "monitoring" }
}

# Object storage
# Uncomment either the `elasticache` or the `s3_os` parameter
elasticache = {
  engine             = "redis"
  engine_version     = "6.x"
  node_type          = "cache.r4.large"
  num_cache_clusters = 2
}

# s3_os = {}

mq = {
  engine_type        = "ActiveMQ"
  engine_version     = "5.17.6"
  host_instance_type = "mq.m5.xlarge"
}

mongodb = {
  node_selector = { service = "state-database" }
}

# Nullify to disable sharding, each nullification of subobject will result in the use of default values 
mongodb_sharding = {}

seq = {
  node_selector = { service = "monitoring" }
}

grafana = {
  node_selector = { service = "monitoring" }
  #persistent_volume = {
  #  storage_provisioner = "efs.csi.aws.com"
  #  resources = {
  #    requests = {
  #      storage = "5Gi"
  #    }
  #  }
  #}
}

node_exporter = {
  node_selector = {
    "service"            = "windows"
    "kubernetes.io/os"   = "windows"
    "kubernetes.io/arch" = "amd64"
  }
}

windows_exporter = {
  node_selector = {
    "plateform" = "windows"
  }
}

prometheus = {
  node_selector = { service = "metrics" }
  #persistent_volume = {
  #  storage_provisioner = "efs.csi.aws.com"
  #  resources = {
  #    requests = {
  #      storage = "5Gi"
  #    }
  #  }
  #}
}

metrics_exporter = {
  node_selector = { service = "metrics" }
}

/*parition_metrics_exporter = {
  node_selector = { service = "metrics" }
  extra_conf    = {
  env = {
    MongoDB__AllowInsecureTls           = true
    Serilog__MinimumLevel               = "Information"
    MongoDB__TableStorage__PollingDelayMin     = "00:00:01"
    MongoDB__TableStorage__PollingDelayMax     = "00:00:10"
    MongoDB__DataRetention = "1.00:00:00"
    }
  }
}*/

fluent_bit = {
  is_daemonset  = true
  image_tag     = "windows-2022-3.0.4"
  node_selector = {}
}

upload_images = false

# Logging level
logging_level = "Debug"

# Parameters of control plane
control_plane = {
  image = "dockerhubaneo/armonik_control"
  tag   = "0.25.0-jgx509store.117.75589619"
  #image_pull_policy = "Always"
  limits = {
    cpu    = "1000m"
    memory = "2048Mi"
  }
  requests = {
    cpu    = "200m"
    memory = "500Mi"
  }
  default_partition = "default"
  node_selector = {
    #service = "control-plane"
    service              = "windows"
    "kubernetes.io/os"   = "windows"
    "kubernetes.io/arch" = "amd64"
  }
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
    node_selector = {
      service = "workers"
    }
    # number of replicas for each deployment of compute plane
    replicas = 1
    # ArmoniK polling agent
    polling_agent = {
      #tag = "0.25.0-jgwinimages.41.9cc8c34a"
      limits = {
        cpu    = "2000m"
        memory = "2048Mi"
      }
      requests = {
        cpu    = "500m"
        memory = "256Mi"
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
          cpu    = "500m"
          memory = "512Mi"
        }
      }
    ]
    hpa = {
      type              = "prometheus"
      polling_interval  = 15
      cooldown_period   = 300
      min_replica_count = 0
      max_replica_count = 100
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
  /*
  # Partition that run the workload on gpu
  gputest = {
    node_selector = { service = "gpu_workers" }
    # number of replicas for each deployment of compute plane
    replicas = 1
    # ArmoniK polling agent
    polling_agent = {
      limits = {
        cpu    = "2000m"
        memory = "2048Mi"
      }
      requests = {
        cpu    = "500m"
        memory = "256Mi"
      }
    }
    # ArmoniK workers
    worker = [
      {
        image = # worker image
        tag   = "latest"
        limits = {
          cpu              = "4000m"
          memory           = "16384Mi"
          "nvidia.com/gpu" = "1"
        }
        requests = {
          cpu              = "2000m"
          memory           = "8192Mi"
          "nvidia.com/gpu" = "1"
        }
      }
    ]
    hpa = {
      type              = "prometheus"
      polling_interval  = 15
      cooldown_period   = 300
      min_replica_count = 0
      max_replica_count = 100
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
  */
  # Partition for the stream worker
  stream = {
    node_selector = { service = "workers" }
    # number of replicas for each deployment of compute plane
    replicas = 1
    # ArmoniK polling agent
    polling_agent = {
      limits = {
        cpu    = "2000m"
        memory = "2048Mi"
      }
      requests = {
        cpu    = "500m"
        memory = "256Mi"
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
          cpu    = "500m"
          memory = "512Mi"
        }
      }
    ]
    hpa = {
      type              = "prometheus"
      polling_interval  = 15
      cooldown_period   = 300
      min_replica_count = 0
      max_replica_count = 100
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
    node_selector = {
      "service"            = "windows"
      "kubernetes.io/os"   = "windows"
      "kubernetes.io/arch" = "amd64"
    }
    # number of replicas for each deployment of compute plane
    replicas = 1
    # ArmoniK polling agent
    polling_agent = {
      tag = "0.25.0-jgx509store.117.75589619"
      limits = {
        cpu    = "2000m"
        memory = "2048Mi"
      }
      requests = {
        cpu    = "500m"
        memory = "256Mi"
      }
    }
    # ArmoniK workers
    worker = [
      {
        image = "dockerhubaneo/armonik_core_htcmock_test_worker"
        tag   = "0.25.0-jgx509store.117.75589619"
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
    hpa = {
      type              = "prometheus"
      polling_interval  = 15
      cooldown_period   = 300
      min_replica_count = 0
      max_replica_count = 100
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
    node_selector = { service = "workers" }
    # number of replicas for each deployment of compute plane
    replicas = 1
    # ArmoniK polling agent
    polling_agent = {
      limits = {
        cpu    = "2000m"
        memory = "2048Mi"
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
    hpa = {
      type              = "prometheus"
      polling_interval  = 15
      cooldown_period   = 300
      min_replica_count = 0
      max_replica_count = 100
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
      Amqp__AllowHostMismatch                    = false
      Amqp__MaxPriority                          = "10"
      Amqp__MaxRetries                           = "5"
      Amqp__QueueStorage__LockRefreshPeriodicity = "00:00:45"
      Amqp__QueueStorage__PollPeriodicity        = "00:00:10"
      Amqp__QueueStorage__LockRefreshExtension   = "00:02:00"
      MongoDB__TableStorage__PollingDelayMin     = "00:00:01"
      MongoDB__TableStorage__PollingDelayMax     = "00:00:10"
      MongoDB__TableStorage__PollingDelay        = "00:00:01"
      MongoDB__DataRetention                     = "1.00:00:00" # 1 day retention
      MongoDB__AllowInsecureTls                  = true
      Redis__Timeout                             = 3000
      Redis__SslHost                             = ""
      Redis__TtlTimeSpan                         = "1.00:00:00" # 1 day retention
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
  name        = "aws-dev"
  version     = "0.0.0"
  description = "AWS environment"
  color       = "#80ff80"
}
