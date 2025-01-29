# Benchmarking ArmoniK on GCP

In this document, we describe the process of benchmarking ArmoniK on Google Cloud Platform (GCP).

## Introduction

This guide provides detailed steps to set up and execute benchmarks for ArmoniK on GCP. The benchmarks follow the [Test Plan](../3.benchmarking/0.test-plan.md).

## Base Commit Used

COMMIT SHA: [hash]()

## Infrastructure Setup

The infrastructure setup is based on Terraform configurations. The reference infrastructure is used for routine benchmarks with each ArmoniK release.

### How to Reproduce the Original Benchmark Infrastructure?

1. Navigate to the GCP quick-deploy directory:
    ```shell
    cd ../../infrastructure/quick-deploy/gcp
    ```

2. Modify the `REGION` variable in the Makefile to the desired region where the infrastructure and machines will be deployed. For our benchmarks, we used `us-central1`, which should also be specified in the `parameters.tfvars` file.

3. Launch the deployment command:
    ```shell
    make deploy PARAMETERS_FILE=benchmarking/gcp/parameters.tfvars VERSIONS_FILE=benchmarking/gcp/versions.tfvars.json
    ```

## Tests Environment

These tests depend on the configuration of the underlying infrastructure and are a prerequisite for every test execution used as a comparison. This method can be reused by anyone desiring to execute our tests.

|        |       |
| ------ | ----- |
| **Date** | [Date] |
| **Infra version** | [Infra version] |
| **Core version** | [Core version] |
| **API version** | [API version] |
| **Extension c# version** | [Extension c# version] |
| **Metrics exporter** | [Metrics exporter] |
| **StressTest Client** | [StressTest Client] |
| **Bench Client** | [Bench Client] |
| **HtcMock Client** | [HtcMock Client] |
| **Instance type** | [Instance type] |

## Note

Do not forget to destroy the infrastructure after the benchmarking is done to avoid unnecessary costs.

## Conclusion

This document provides a comprehensive guide to benchmarking ArmoniK on GCP. By following the steps outlined, you can reproduce the benchmark infrastructure and execute the tests as described in the [Test Plan](../3.benchmarking/0.test-plan.md).
