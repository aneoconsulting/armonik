locals {
  mongodb_image_name = can(coalesce(var.mongodb_sharding)) ? coalesce(var.mongodb.image_name, "bitnami/mongodb-sharded") : coalesce(var.mongodb.image_name, "bitnami/mongodb")
  ecr_input_images = concat([
    [var.eks.docker_images.cluster_autoscaler.image, var.eks.docker_images.cluster_autoscaler.tag],
    [var.eks.docker_images.instance_refresh.image, var.eks.docker_images.instance_refresh.tag],
    [var.metrics_server.image_name, var.metrics_server.image_tag],
    [var.keda.keda_image_name, var.keda.keda_image_tag],
    [var.keda.apiserver_image_name, var.keda.apiserver_image_tag],
    [local.mongodb_image_name, var.mongodb.image_tag],
    [var.prometheus.image_name, var.prometheus.image_tag],
    [var.fluent_bit.image_name, var.fluent_bit.image_tag],
    [var.metrics_exporter.image_name, var.metrics_exporter.image_tag],
    [var.job_partitions_in_database.image, var.job_partitions_in_database.tag],
    [var.admin_gui.image, var.admin_gui.tag],
    [var.control_plane.image, var.control_plane.tag],
    [var.eks.docker_images.efs_csi.image, var.eks.docker_images.efs_csi.tag],
    [var.eks.docker_images.ebs_csi.image, var.eks.docker_images.ebs_csi.tag],
    [var.eks.docker_images.csi_liveness_probe.image, var.eks.docker_images.csi_liveness_probe.tag],
    [var.eks.docker_images.csi_node_driver_registrar.image, var.eks.docker_images.csi_node_driver_registrar.tag],
    [var.eks.docker_images.csi_external_provisioner.image, var.eks.docker_images.csi_external_provisioner.tag],
    var.seq == null ? null : [var.seq.image_name, var.seq.image_tag],
    var.seq == null ? null : [var.seq.cli_image_name, var.seq.cli_image_tag],
    var.grafana == null ? null : [var.grafana.image_name, var.grafana.image_tag],
    var.node_exporter == null ? null : [var.node_exporter.image_name, var.node_exporter.image_tag],
    var.windows_exporter == null ? null : [var.windows_exporter.image_name, var.windows_exporter.image_tag],
    var.windows_exporter == null ? null : [var.windows_exporter.init_image_name, var.windows_exporter.init_image_tag],
    var.partition_metrics_exporter == null ? null : [var.partition_metrics_exporter.image_name, var.partition_metrics_exporter.image_tag],
    var.ingress == null ? null : [var.ingress.image, var.ingress.tag],
    var.authentication == null ? null : [var.authentication.image, var.authentication.tag],
    var.pod_deletion_cost == null ? null : [var.pod_deletion_cost.image, var.pod_deletion_cost.tag],
    ], [for k, v in var.compute_plane :
    [v.polling_agent.image, v.polling_agent.tag]
    ], concat([for k, v in var.compute_plane :
      [for w in v.worker :
        [w.image, w.tag]
      ]
  ]...))

  ecr_input_images_step1 = toset([
    for image in local.ecr_input_images :
    {
      name = image[0]
      tag  = try(coalesce(image[1]), local.default_tags[image[0]])
    }
    if image != null
  ])

  ecr_input_images_step2 = [
    for image in local.ecr_input_images_step1 :
    {
      key        = "${image.name}:${image.tag}"
      components = split("/", image.name)
      name       = image.name
      tag        = image.tag
    }
  ]

  ecr_repositories = [for image in local.ecr_input_images_step2 : {
    key   = image.key
    name  = replace("${local.prefix}-${substr(md5(image.key), 0, 8)}-${image.components[length(image.components) - 1]}", "_", "-")
    image = image.name
    tag   = image.tag
  }]

  ecr_images_raw = { for rep in local.ecr_repositories :
    rep.key => var.upload_images ? {
      image = try(module.ecr.repositories[rep.name], null),
      name  = try(module.ecr.repositories[rep.name], null),
      tag   = rep.tag,
      } : {
      image = rep.image,
      name  = rep.image,
      tag   = rep.tag,
    }
  }

  ecr_images = merge(local.ecr_images_raw, {
    for name, tag in local.default_tags :
    "${name}:" => local.ecr_images_raw["${name}:${tag}"]
    if can(local.ecr_images_raw["${name}:${tag}"])
  })

  repositories = { for element in local.ecr_repositories : element.name => {
    image = element.image
    tag   = element.tag
    }
  }

  default_tags = module.default_images.image_tags
}

# Default tags for all images
module "default_images" {
  source           = "./generated/infra-modules/utils/default-images"
  armonik_versions = var.armonik_versions
  armonik_images   = var.armonik_images
  image_tags       = var.image_tags
}

module "ecr" {
  source          = "./generated/infra-modules/container-registry/aws/ecr"
  aws_profile     = var.profile
  kms_key_id      = local.kms_key
  repositories    = var.upload_images ? local.repositories : {}
  encryption_type = var.ecr.encryption_type
  tags            = local.tags
}
