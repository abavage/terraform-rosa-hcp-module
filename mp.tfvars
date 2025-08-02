machine_pools = {
  pool-0 = {
    name = "pool-0"
    aws_node_pool = {
      instance_type = "m5.xlarge"
      tags = local.tags
      additional_security_group_ids = [""]
    }
    labels = local.labels
    taints = local.taints
    auto_repair = true
    replicas = 1
    openshift_version = var.openshift_version
    subnet_id = data.aws_subnets.private_subnets.ids[0]
  }

  pool-1 = {
    name = "pool-1"
    aws_node_pool = {
      instance_type = "m5.xlarge"
      tags = local.tags
      additional_security_group_ids = [""]
    }
    labels = local.labels
    taints = local.taints
    auto_repair = true
    replicas = 0
    openshift_version = var.openshift_version
    subnet_id = data.aws_subnets.private_subnets.ids[1]
  }

  pool-2 = {
    name = "pool-2"
    aws_node_pool = {
      instance_type = "m5.xlarge"
      tags = local.tags
      additional_security_group_ids = [""]
    }
    labels = local.labels
    taints = local.taints
    auto_repair = true
    replicas = 0
    openshift_version = var.openshift_version
    subnet_id = data.aws_subnets.private_subnets.ids[2]
  }
}