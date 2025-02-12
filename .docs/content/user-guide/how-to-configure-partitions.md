<!-- @case-police-ignore Grpc -->

# How to configure partitions?

This guide aims to present the setup and usage of the partitions within ArmoniK.

## What partitioning means in ArmoniK

Partitions are sets of pods with their own configuration, their own task queue and their own scaling rules. Partitioning is useful in the following use-cases (non-exhaustive):

- workers need different images
- workers need different node configuration (eg: number of cores, gpu)
- need different limits on the number of pods depending on the application

## How to setup the partitioning in terraform

To install and configure the partitioning there are some modifications to implement in the deployment scripts.  With the implementation in the 2.9 version, the partitioning is static. That means, that the partitions have to be defined and deployed at the same time than the ArmoniK infrastructure and cannot be changed without a redeployment and a new modification of the parameters files.

In the version 2.8, the partitioning was not available in ArmoniK but the infrastructure was ready for this functionality. A default partition was created at deployment time with the name `default`.

To use multiple partitions, a functionality which is now available with the version 2.9,  the first step is to modify the infrastructure deployment with the desired configuration  for the partitions. On an AWS deployment, this is done in the file  [infrastructure/quick-deploy/*/parameters.tfvars](https://github.com/aneoconsulting/ArmoniK/blob/main/infrastructure/quick-deploy/aws/parameters.tfvars), specifically in the variable `compute_plane`.

This variable is a map whose key is the partition name and the value is the partition configuration.

```hcl
# Parameters of the compute plane
variable "compute_plane" {
  description = "Parameters of the compute plane"
  type = map(object({
    replicas                         = number
    termination_grace_period_seconds = number
    image_pull_secrets               = string
    node_selector                    = any
    annotations                      = any
    polling_agent = object({
      image             = string
      tag               = string
      image_pull_policy = string
      limits = object({
        cpu    = string
        memory = string
      })
      requests = object({
        cpu    = string
        memory = string
      })
    })
    worker = list(object({
      name              = string
      image             = string
      tag               = string
      image_pull_policy = string
      limits = object({
        cpu    = string
        memory = string
      })
      requests = object({
        cpu    = string
        memory = string
      })
    }))
    hpa = any
  }))
}
```

You can set a default partition in the parameters of the control plane `control_plane.default_partition`. The default partition must exist in the compute_plane.

Here is an example in which 2 partitions are created:
- `partition1`: default partition, use the image `my-application-1:0.8.1` without any node selector
- `partition2`: use the image `my-application-2:0.3.2`, on spot nodes (preemptible nodes)

```hcl
# Parameters of control plane
control_plane = {
  # ...
  default_partition = "partition1"
}

# Parameters of the compute plane
compute_plane = {
  # Description of the `partition1` partition
  partition1 = {
    # number of replicas for each deployment of compute plane
    replicas                         = 1
    termination_grace_period_seconds = 30
    image_pull_secrets               = ""
    node_selector                    = {}
    annotations                      = {}
    # ArmoniK polling agent
    polling_agent = # ...
    # ArmoniK workers
    worker = [
      {
        name              = "worker"
        image             = "my-application-1"
        tag               = "0.8.1"
        image_pull_policy = "IfNotPresent"
        limits            = null # no limit
        requests          = null # no request
      }
    ]
    # Horizontal Pod Autoscaler configuration
    hpa = # ...
  },
  # Description of the `partition2` partition
  partition2 = {
    # number of replicas for each deployment of compute plane
    replicas                         = 1
    termination_grace_period_seconds = 30
    image_pull_secrets               = ""
    node_selector                    = { node = "SPOT" }
    annotations                      = {}
    # ArmoniK polling agent
    polling_agent = # ...
    # ArmoniK workers
    worker = [
      {
        name              = "worker"
        image             = "my-application-2"
        tag               = "0.3.2"
        image_pull_policy = "IfNotPresent"
        limits            = null # no limit
        requests          = null # no request
      }
    ]
    # Horizontal Pod Autoscaler configuration
    hpa = # ...
  },
}
```

## Use a partition when submitting tasks with UnifiedAPI

The partition to use is defined when creating the session, by setting the default `TaskOptions` of the session. The partition must exist, otherwise an error is raised.

```c#
TaskOptions = new TaskOptions{
    MaxDuration          = new Duration { Seconds = 3600 * 24 },
    MaxRetries           = 3,
    Priority             = 1,
    EngineType           = EngineType.Unified.ToString(),
    ApplicationVersion   = "1.0.0-700",
    ApplicationService   = "ServiceApps",
    ApplicationName      = "ArmoniK.Samples.Unified.Worker",
    ApplicationNamespace = "ArmoniK.Samples.Unified.Worker.Services",
    // This is where you set the partition
    PartitionId          = "partition1",
};

Props = new Properties(
    TaskOptions,
    configuration.GetSection("Grpc")["EndPoint"],
    5001
);

Service = ServiceFactory.CreateService(Props, loggerFactory);
```

If you set the `PartitionId` to empty (`""`), the default partition will be used.



```{warning}


It is an error to set the `PartitionId` to `null`.

```

## Use a partition when submitting tasks with native gRPC API

In order to use partitions with the native gRPC API, you must specify at the session creation the partitions that will be used by the tasks of this session. This is done with the field `PartitionIds` which is the list of the partitions available to the tasks. You can set it to an empty list or a list containing only a single empty string to use the default partition during the session. You can also define the default partition to be used by the tasks of the session in the `defaultTaskOption`. An empty `DefaultTaskOption.PartitionId` is replaced by the default partition of the *cluster*. If a partition does not exist, an error is raised.

```c#
var createSessionRequest = new CreateSessionRequest{
    DefaultTaskOption = new TaskOptions{
        MaxDuration = Duration.FromTimeSpan(TimeSpan.FromHours(1)),
        MaxRetries  = 2,
        Priority    = 1,
        PartitionId = "partition2",
    },
    PartitionIds = { "partition1", "partition2" },
};
var createSessionReply = submitterClient.CreateSession(createSessionRequest);
```

You can specify a specific partition for a task by overwriting the `TaskOptions` for the task and specifying a different partition. If `PartitionId` is empty, the default partition of the *session* will be used. An error is raised if the specified partition is not part of the list of partitions of the session.

```c#
var createTaskReply = await submitterClient.CreateTasksAsync(
    createSessionReply.SessionId,
    new TaskOptions{
      MaxDuration = Duration.FromTimeSpan(TimeSpan.FromHours(1)),
      MaxRetries  = 2,
      Priority    = 1,
      PartitionId = "partition1",
    },
    /* ... requests ... */
);
```



```{warning}


It is an error to set the `PartitionId` to `null`.

```

## Add a partition for the HelloWorld worker

Follow the HelloWorld tutorial [here](https://github.com/aneoconsulting/ArmoniK/blob/main/.docs/content/2.guide/how-to-launch-HelloWorld-Sample)

```terraform

 # Partition for the helloworld worker
  helloworld = {
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
        image = "hello"
        tag = "latest"
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
        }
      ]
    }
  },
  ```
