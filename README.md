# ArmoniK

[![Generic badge](https://img.shields.io/badge/Status-Stable-green.svg)](https://shields.io/) [![GitHub License Core](https://img.shields.io/github/license/aneoconsulting/ArmoniK)](https://github.com/aneoconsulting/ArmoniK/blob/main/LICENSE)
[![GitHub Release](https://img.shields.io/github/v/release/aneoconsulting/ArmoniK)](https://github.com/aneoconsulting/ArmoniK/releases) 
[![Docker Image Version (latest semver)](https://img.shields.io/docker/v/aneoconsulting/armonik_core?sort=semver)](https://hub.docker.com/r/aneoconsulting/armonik_core/tags)

ArmoniK is an open-source high throughput compute grid built on Kubernetes. It provides a scalable and robust framework for running large volumes of compute tasks.

## Introduction

ArmoniK allows users to submit high volumes of short and long-running compute tasks, while dynamically scaling the underlying infrastructure to meet demand. It is designed as a reference architecture that can be deployed on-premise or in the cloud.

The project aims to provide a modern, Kubernetes-native solution for high performance computing applications. 

## What is ArmoniK?

ArmoniK consists of several components:

- A control plane for handling task submission and coordination
- A scalable compute plane for running tasks  
- Integrations with storage, networking, monitoring, and other services
- Client libraries and tools for interfacing with the system

Together, these components allow ArmoniK to accept compute tasks, distribute them to workers, execute the tasks, and return results. The architecture is horizontally scalable, fault tolerant, and provides detailed monitoring.

## When should I use ArmoniK? 

ArmoniK is designed for workloads that require:

- High throughput of compute tasks
- Dynamic scaling of resources 
- Low overhead and high efficiency
- Detailed monitoring and analytics   
- Integration of on-premise and cloud infrastructure
- Static or dynamic graph of tasks creation and then tasks creation itself
- Communicate with ArmoniK through 11 different languages via gRPC APIs
- Admin GUI for monitoring
- Enterprise security compliance
- Client-server communications, roles and permissions controlled by mutual TLS authentication 
- Ability to partition resources (hardware, software, application versions)
- Extensions provide abstraction from the orchestrator, some resemble known APIs to facilitate integration
- Ability to leverage Linux, Windows, CPU, GPU resources
- Cloud provider agnostic while utilizing cloud provider services  
- Activity log visualization via fluent-bit connectors
- Resource and task monitoring via Grafana, Prometheus, Admin GUI

Use cases include:

- Scientific computing / HPC
- Financial analysis
- Machine learning / data processing   
- Video encoding / transcoding 
- Genomics / bioinformatics
- Rendering / graphics
- Any batch processing workload

## Want a quickstart?

Get started with ArmoniK by following the quickstart guide:

[Quickstart guide](https://armonik.readthedocs.io/en/latest/installation/linux/deployment/)

Or try deploying ArmoniK locally on your machine.

## Features

- Horizontally scalable architecture  
- gRPC APIs for task management (11 language clients)
- Admin GUI for monitoring
- Enterprise security compliance
- Mutual TLS authentication
- Partitioning of resources
- Extensions for simplified integration
- Multi-cloud and on-premise support 
- Detailed monitoring with Grafana, Prometheus, etc.
- Dynamic scaling through Kubernetes
- Client SDKs for .NET, Python, C++, and more

## Repository 

The source code for ArmoniK is available on GitHub:

[https://github.com/aneoconsulting/ArmoniK](https://github.com/aneoconsulting/ArmoniK)

The components are spread across multiple repositories:

- [ArmoniK.Core](https://github.com/aneoconsulting/ArmoniK.Core) - The core logic of ArmoniK
- [ArmoniK.Api](https://github.com/aneoconsulting/ArmoniK.Api) - The gRPC APIs 
- [ArmoniK.Extensions.Csharp](https://github.com/aneoconsulting/ArmoniK.Extensions.Csharp) - The C# extensions
- [ArmoniK.Extensions.Cpp](https://github.com/aneoconsulting/ArmoniK.Extensions.Cpp) - The C++ extensions


## Releases

The latest ArmoniK releases are available on [GitHub](https://github.com/aneoconsulting/ArmoniK/releases) and [Docker Hub](https://hub.docker.com/u/dockerhubaneo).



## Benchmarking  

Performance benchmarks for ArmoniK are available here:

[Benchmark results](https://aneoconsulting.github.io/ArmoniK/benchmarking/test-plan/)

## Resources  

### Documentation

Please, read [documentation](https://aneoconsulting.github.io/ArmoniK/) for more information about ArmoniK.

👉 [ArmoniK Architecture](https://aneoconsulting.github.io/ArmoniK/armonik)
👉 [ArmoniK Versions](https://aneoconsulting.github.io/ArmoniK/armonik#versions)
👉 [ArmoniK Installation](https://aneoconsulting.github.io/ArmoniK/installation)
👉 [ArmoniK Configuration](https://aneoconsulting.github.io/ArmoniK/guide/how-to/how-to-configure-authentication)
👉 [ArmoniK Performance](https://aneoconsulting.github.io/ArmoniK/benchmarking/test-plan)

👉 [Blog]   
👉 [YouTube videos]

## Contributing

ArmoniK is open source and welcomes contributions. See the our [community guidelines](https://aneoconsulting.github.io/ArmoniK.Community/) before doing so.

- Report bugs by [opening an issue](https://github.com/aneoconsulting/ArmoniK/issues) 
- Suggest new features by [opening an issue](https://github.com/aneoconsulting/ArmoniK/issues)
- Improve documentation by submitting a pull request
- Find good first issues to work on with the [good first issue](https://github.com/aneoconsulting/ArmoniK/issues?q=is%3Aopen+is%3Aissue+label%3A%22good+first+issue%22) tag 
- You can also send us a direct email at [armonik-support@aneo.fr](mailto:armonik-support@aneo.fr).


## License

**ArmoniK.Core** is licensed under the [AGPL v3](https://github.com/aneoconsulting/ArmoniK.Core/blob/main/LICENSE) license.  

Other components are under the [Apache 2](https://github.com/aneoconsulting/ArmoniK/blob/main/LICENSE) license.

[Organization 1]: https://armonik.fr
[Organization 2]: https://aneo.fr   
[Blog]: Soon
[YouTube videos]: https://example.com



