module "armonik" {
  source        = "./generated/infra-modules/armonik"
  namespace     = local.namespace
  logging_level = var.logging_level

  configurations = merge(var.configurations, {
    core = [module.activemq, module.mq, module.elasticache, module.mongodb, module.mongodb_sharded, var.configurations.core]
  })

  fluent_bit              = module.fluent_bit
  grafana                 = one(module.grafana)
  prometheus              = module.prometheus
  metrics                 = module.metrics_exporter
  seq                     = one(module.seq)
  shared_storage_settings = local.shared_storage

  // If compute plane has no partition data, provides a default
  // but always overrides the images
  compute_plane = { for k, v in var.compute_plane : k => merge({
    partition_data = {
      priority              = 1
      reserved_pods         = 1
      max_pods              = 100
      preemption_percentage = 50
      parent_partition_ids  = []
      pod_configuration     = null
    }
    }, v, {
    service_account_name = "armonikserviceaccount"
    polling_agent = merge(v.polling_agent, {
      image = local.ecr_images["${v.polling_agent.image}:${try(coalesce(v.polling_agent.tag), "")}"].name
      tag   = local.ecr_images["${v.polling_agent.image}:${try(coalesce(v.polling_agent.tag), "")}"].tag
    })
    worker = [for w in v.worker : merge(w, {
      image = local.ecr_images["${w.image}:${try(coalesce(w.tag), "")}"].name
      tag   = local.ecr_images["${w.image}:${try(coalesce(w.tag), "")}"].tag
    })]
  }) }
  control_plane = merge(var.control_plane, {
    image                = local.ecr_images["${var.control_plane.image}:${try(coalesce(var.control_plane.tag), "")}"].name
    tag                  = local.ecr_images["${var.control_plane.image}:${try(coalesce(var.control_plane.tag), "")}"].tag
    service_account_name = "armonikserviceaccount"
  })
  admin_gui = merge(var.admin_gui, {
    image = local.ecr_images["${var.admin_gui.image}:${try(coalesce(var.admin_gui.tag), "")}"].name
    tag   = local.ecr_images["${var.admin_gui.image}:${try(coalesce(var.admin_gui.tag), "")}"].tag
  })
  ingress = merge(var.ingress, {
    image = local.ecr_images["${var.ingress.image}:${try(coalesce(var.ingress.tag), "")}"].name
    tag   = local.ecr_images["${var.ingress.image}:${try(coalesce(var.ingress.tag), "")}"].tag
  })
  job_partitions_in_database = merge(var.job_partitions_in_database, {
    image = local.ecr_images["${var.job_partitions_in_database.image}:${try(coalesce(var.job_partitions_in_database.tag), "")}"].name
    tag   = local.ecr_images["${var.job_partitions_in_database.image}:${try(coalesce(var.job_partitions_in_database.tag), "")}"].tag
  })
  authentication = merge(var.authentication, {
    image = local.ecr_images["${var.authentication.image}:${try(coalesce(var.authentication.tag), "")}"].name
    tag   = local.ecr_images["${var.authentication.image}:${try(coalesce(var.authentication.tag), "")}"].tag
  })

  # Force the dependency on Keda and metrics-server for the HPA
  keda_chart_name           = module.keda.keda.chart_name
  metrics_server_chart_name = concat(module.metrics_server[*].metrics_server.chart_name, ["metrics-server"])[0]

  environment_description = var.environment_description
  static                  = var.static

  #metrics_exporter
  metrics_exporter = {
    image              = local.ecr_images["${var.metrics_exporter.image_name}:${try(coalesce(var.metrics_exporter.image_tag), "")}"].image
    tag                = local.ecr_images["${var.metrics_exporter.image_name}:${try(coalesce(var.metrics_exporter.image_tag), "")}"].tag
    image_pull_secrets = var.metrics_exporter.pull_secrets
    node_selector      = var.metrics_exporter.node_selector
  }

  # Pod Deletion Cost updater
  pod_deletion_cost = merge(var.pod_deletion_cost, {
    image = local.ecr_images["${var.pod_deletion_cost.image}:${try(coalesce(var.pod_deletion_cost.tag), "")}"].image
    tag   = local.ecr_images["${var.pod_deletion_cost.image}:${try(coalesce(var.pod_deletion_cost.tag), "")}"].tag
  })

  depends_on = [module.aws_service_account]
}
