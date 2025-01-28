# AWS EKS
module "eks" {
  source                 = "./generated/infra-modules/kubernetes/aws/eks"
  profile                = var.profile
  tags                   = local.tags
  name                   = module.vpc.eks_cluster_name
  node_selector          = var.eks.node_selector
  kubeconfig_file        = abspath(var.kubeconfig_file)
  vpc_id                 = module.vpc.id
  vpc_private_subnet_ids = module.vpc.private_subnets
  vpc_pods_subnet_ids    = module.vpc.pod_subnets

  cluster_autoscaler_image                                 = local.ecr_images["${var.eks.docker_images.cluster_autoscaler.image}:${try(coalesce(var.eks.docker_images.cluster_autoscaler.tag), "")}"].image
  cluster_autoscaler_tag                                   = local.ecr_images["${var.eks.docker_images.cluster_autoscaler.image}:${try(coalesce(var.eks.docker_images.cluster_autoscaler.tag), "")}"].tag
  cluster_autoscaler_expander                              = var.eks.cluster_autoscaler.expander
  cluster_autoscaler_scale_down_enabled                    = var.eks.cluster_autoscaler.scale_down_enabled
  cluster_autoscaler_min_replica_count                     = var.eks.cluster_autoscaler.min_replica_count
  cluster_autoscaler_scale_down_utilization_threshold      = var.eks.cluster_autoscaler.scale_down_utilization_threshold
  cluster_autoscaler_scale_down_non_empty_candidates_count = var.eks.cluster_autoscaler.scale_down_non_empty_candidates_count
  cluster_autoscaler_max_node_provision_time               = var.eks.cluster_autoscaler.max_node_provision_time
  cluster_autoscaler_scan_interval                         = var.eks.cluster_autoscaler.scan_interval
  cluster_autoscaler_scale_down_delay_after_add            = var.eks.cluster_autoscaler.scale_down_delay_after_add
  cluster_autoscaler_scale_down_delay_after_delete         = var.eks.cluster_autoscaler.scale_down_delay_after_delete
  cluster_autoscaler_scale_down_delay_after_failure        = var.eks.cluster_autoscaler.scale_down_delay_after_failure
  cluster_autoscaler_scale_down_unneeded_time              = var.eks.cluster_autoscaler.scale_down_unneeded_time
  cluster_autoscaler_skip_nodes_with_system_pods           = var.eks.cluster_autoscaler.skip_nodes_with_system_pods
  cluster_autoscaler_version                               = try(coalesce(var.eks.cluster_autoscaler.version), var.helm_charts.cluster_autoscaler.version)
  cluster_autoscaler_repository                            = try(coalesce(var.eks.cluster_autoscaler.repository), var.helm_charts.cluster_autoscaler.repository)
  cluster_autoscaler_namespace                             = var.eks.cluster_autoscaler.namespace

  instance_refresh_image      = local.ecr_images["${var.eks.docker_images.instance_refresh.image}:${try(coalesce(var.eks.docker_images.instance_refresh.tag), "")}"].image
  instance_refresh_tag        = local.ecr_images["${var.eks.docker_images.instance_refresh.image}:${try(coalesce(var.eks.docker_images.instance_refresh.tag), "")}"].tag
  instance_refresh_version    = try(coalesce(var.eks.instance_refresh.version), var.helm_charts.termination_handler.version)
  instance_refresh_repository = try(coalesce(var.eks.instance_refresh.repository), var.helm_charts.termination_handler.repository)
  instance_refresh_namespace  = var.eks.instance_refresh.namespace

  efs_csi = {
    image      = local.ecr_images["${var.eks.docker_images.efs_csi.image}:${try(coalesce(var.eks.docker_images.efs_csi.tag), "")}"].image
    tag        = local.ecr_images["${var.eks.docker_images.efs_csi.image}:${try(coalesce(var.eks.docker_images.efs_csi.tag), "")}"].tag
    repository = try(coalesce(var.eks.efs_csi.repository), var.helm_charts.efs_csi_driver.repository)
    version    = try(coalesce(var.eks.efs_csi.version), var.helm_charts.efs_csi_driver.version)
  }

  ebs_csi = {
    image      = local.ecr_images["${var.eks.docker_images.ebs_csi.image}:${try(coalesce(var.eks.docker_images.ebs_csi.tag), "")}"].image
    tag        = local.ecr_images["${var.eks.docker_images.ebs_csi.image}:${try(coalesce(var.eks.docker_images.ebs_csi.tag), "")}"].tag
    repository = try(coalesce(var.eks.ebs_csi.repository), var.helm_charts.ebs_csi_driver.repository)
    version    = try(coalesce(var.eks.ebs_csi.version), var.helm_charts.ebs_csi_driver.version)
  }

  csi_liveness_probe = {
    image = local.ecr_images["${var.eks.docker_images.csi_liveness_probe.image}:${try(coalesce(var.eks.docker_images.csi_liveness_probe.tag), "")}"].image
    tag   = local.ecr_images["${var.eks.docker_images.csi_liveness_probe.image}:${try(coalesce(var.eks.docker_images.csi_liveness_probe.tag), "")}"].tag
  }
  csi_node_driver_registrar = {
    image = local.ecr_images["${var.eks.docker_images.csi_node_driver_registrar.image}:${try(coalesce(var.eks.docker_images.csi_node_driver_registrar.tag), "")}"].image
    tag = local.ecr_images["${var.eks.docker_images.csi_node_driver_registrar.image}:${try(coalesce(var.eks.docker_images.csi_node_driver_registrar.tag), "")}"].tag
  }
  csi_external_provisioner = {
    image = local.ecr_images["${var.eks.docker_images.csi_external_provisioner.image}:${try(coalesce(var.eks.docker_images.csi_external_provisioner.tag), "")}"].image
    tag = local.ecr_images["${var.eks.docker_images.csi_external_provisioner.image}:${try(coalesce(var.eks.docker_images.csi_external_provisioner.tag), "")}"].tag
  }

  cluster_log_kms_key_id    = local.kms_key
  cluster_encryption_config = local.kms_key
  ebs_kms_key_id            = local.kms_key

  cluster_version                      = var.eks.cluster_version
  cluster_endpoint_private_access      = var.eks.cluster_endpoint_private_access
  cluster_endpoint_public_access       = var.eks.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.eks.cluster_endpoint_public_access_cidrs
  cluster_log_retention_in_days        = var.eks.cluster_log_retention_in_days

  eks_managed_node_groups  = var.eks_managed_node_groups
  self_managed_node_groups = var.self_managed_node_groups
  fargate_profiles         = var.fargate_profiles
}

resource "kubernetes_namespace" "armonik" {
  metadata {
    name = var.namespace
  }

  depends_on = [module.eks]
}

locals {
  namespace = kubernetes_namespace.armonik.metadata[0].name
}
