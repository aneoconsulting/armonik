# ArmoniK

ArmoniK is a high throughput compute grid project using Kubernetes.

It provides a reference architecture that can be used to build and adapt a modern high throughput compute solution on-premise or using Cloud services, allowing users to submit high volumes of short and long-running tasks and scaling environments dynamically.



```{note}


This project is an Open Source ([Apache 2.0 License](https://github.com/aneoconsulting/ArmoniK/blob/main/LICENSE)).

```

Here is an overview of how Armonik works:
![Armonik overview diagram](./architecture-ArmoniK-internals.svg)

## When should I use ArmoniK

ArmoniK should be used when the following criteria are met:

1. A high task throughput is required (from 250 to 10,000+ tasks per second).
2. The tasks are loosely coupled.
3. Variable workloads (tasks with heterogeneous execution times) are expected and the solution needs to dynamically scale with the load.

## Versions

The current version of ArmoniK uses the tags listed in [versions.tfvars.json](https://github.com/aneoconsulting/ArmoniK/blob/main/versions.tfvars.json) where:

- `armonik` is the tag of the main repository of [ArmoniK](https://github.com/aneoconsulting/ArmoniK)
- `infra` is the tag of [ArmoniK.Infra](https://github.com/aneoconsulting/ArmoniK.Infra) repository which host the infrastructure modules
- `core` is the tag of [ArmoniK.Core](https://github.com/aneoconsulting/ArmoniK.Core) repository used for container images of Control plane, Polling agent and Metrics exporter
- `api` is the tag of [ArmoniK.Api](https://github.com/aneoconsulting/ArmoniK.Api) repository (informative only)
- `gui` is the tag of [ArmoniK.Admin.GUI](https://github.com/aneoconsulting/ArmoniK.Admin.GUI) repository used for container images of ArmoniK AdminGUI
- `extcsharp` is the tag of [ArmoniK.Extensions.Csharp](https://github.com/aneoconsulting/ArmoniK.Extensions.Csharp) repository used for container images of the DLL worker
- `samples` is the tag of [ArmoniK.Samples](https://github.com/aneoconsulting/ArmoniK.Samples) repository
