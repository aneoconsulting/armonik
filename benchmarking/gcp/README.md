# ArmoniK benchmarking on GCP
This directory includes two Terraform configuration files: one detailing the infrastructure designated as the *ArmoniK reference infrastructure on GCP*, which is utilized for routine benchmarks with each ArmoniK release, and another specifying the versions of all components used when this reference infrastructure was set up, primarily for reproducibility.

### Base commit used
COMMIT SHA: [hash]()

### How to reproduce the original benchmark infrastructure?
1. Go to GCP quick-deploy: 
```shell
cd ../../infrastructure/quick-deploy/gcp`
```

2. Modify in the Makefile variable `REGION` to the desired region where the infrastructure and machines available are to be deployed. In our case, we used `us-central1` that will be used also in the `parameters.tfvars` file.

3. Launch the deployment command:

```shell
make deploy PARAMETERS_FILE=benchmarking/gcp/parameters.tfvars VERSIONS_FILE=benchmarking/gcp/versions.tfvars.json
```


### Note

Do not forget to destroy the infrastructure after the benchmarking is done to avoid unnecessary costs.
