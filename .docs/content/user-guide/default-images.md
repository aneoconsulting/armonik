<!-- TODO: need have a new title -->

# Default images

The terraform deployments support to omit the image names and tags in the tfvars.

If the image name is omitted, a default image name is used, specified directly in [`variables.tf`](https://github.com/aneoconsulting/ArmoniK/blob/main/infrastructure/quick-deploy/localhost/variables.tf).
If the image tag is omitted, the default tag for this very image is used.
The default tags are defined in [`versions.tfvars.json`](https://github.com/aneoconsulting/ArmoniK/blob/main/versions.tfvars.json).

For all ArmoniK images, the default tag correspond to the version (in [`armonik_versions`](https://github.com/aneoconsulting/ArmoniK/blob/main/versions.tfvars.json#L2...L9) variable) of the ArmoniK component that generates the image (in [`armonik_images`](https://github.com/aneoconsulting/ArmoniK/blob/main/versions.tfvars.json#L10...L36) variable).
For third-party images, the default tag of an image is defined in [`image_tags`](https://github.com/aneoconsulting/ArmoniK/blob/main/versions.tfvars.json#L37...L58) variable.

You are still be able to specify custom image names and/or image tags in your tfvars if you want, without needing to modify [`versions.tfvars.json`](https://github.com/aneoconsulting/ArmoniK/blob/main/versions.tfvars.json).
If you try to use an image name that is not listed in [`versions.tfvars.json`](https://github.com/aneoconsulting/ArmoniK/blob/main/versions.tfvars.json), you are required to also specify a tag for this image.

## Examples

All the examples are for the all-in-one local deployment for mongodb, with the following default versions:

```json
{
  "armonik_versions": {
    "core": "0.8.3",
    "extcsharp": "0.8.1",
    ...
  },
  "armonik_images": {
    "core": [
      "dockerhubaneo/armonik_control",
      "dockerhubaneo/armonik_core_bench_test_worker",
      ...
    ],
    "extcsharp": [
      "dockerhubaneo/armonik_worker_dll"
    ],
    ...
  },
  "image_tags": {
    "mongo": "5.0.9",
    ...
  }
}
```

Specifying the image and its version within the tfvars (ex: [`parameters.tfvars`](https://github.com/aneoconsulting/ArmoniK/blob/main/infrastructure/quick-deploy/aws/parameters.tfvars))

## Use the default image and tag

```terraform
mongodb = {
}

control_plane = {
  default_partition = ...
}
```

- mongodb: `mongo:5.0.9`
- control_plane: `dockerhubaneo/armonik_control:0.8.3`

## Use the default image with a custom tag

```terraform
mongodb = {
  image_tag = "6.0"
}

control_plane = {
  image_tag = "0.8.0"
  default_partition = ...
}
```

- mongodb: `mongo:6.0`
- control_plane: `dockerhubaneo/armonik_control:0.8.0`

## Use a custom image

```terraform
mongodb = {
  image_name = "custom_registry/mongo"
  image_tag  = "6.0" # required
}

control_plane = {
  image_name = "custom_registry/custom_armonik_control"
  image_tag  = "0.8.3" # required
  default_partition = ...
}
```

- mongodb: `custom_registry/mongo:6.0`
- control_plane: `custom_registry/custom_armonik_control:0.8.3`

### Special case of the workers

There is no default image for the workers, but you can still omit the tag if the image is listed in [`versions.tfvars.json`](https://github.com/aneoconsulting/ArmoniK/blob/main/versions.tfvars.json):

```terraform
compute_plane = {
  partition1 = {
    worker = [{
        image = "dockerhubaneo/armonik_core_bench_test_worker"
      }]
  }
  partition2 = {
    worker = [{
        image = "dockerhubaneo/armonik_worker_dll"
      }]
  }
  partition3 = {
    worker = [{
        image = "dockerhubaneo/armonik_worker_dll"
        tag   = "0.8.0"
      }]
  }
  partition4 = {
    worker = [{
        image = "custom_worker"
        tag   = "0.1.0"
      }]
  }
}
```

Workers:
- partition1: `dockerhubaneo/armonik_core_bench_test_worker:0.8.3`
- partition2: `dockerhubaneo/armonik_worker_dll:0.8.1`
- partition3: `dockerhubaneo/armonik_worker_dll:0.8.0`
- partition4: `custom_worker:0.1.0`
