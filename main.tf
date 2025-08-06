module "oidc_config_and_provider" {
  source = "terraform-redhat/rosa-hcp/rhcs//modules/oidc-config-and-provider"
  #version = "1.6.9"
  
}

module "account_iam_resources" {
  source = "terraform-redhat/rosa-hcp/rhcs//modules/account-iam-resources"
  #version = "1.6.9"

  account_role_prefix  = var.cluster_name
  path                 = var.path
}

module "operator_roles" {
  source = "terraform-redhat/rosa-hcp/rhcs//modules/operator-roles"
  #version = "1.6.9"

  operator_role_prefix = var.cluster_name
  oidc_endpoint_url    = module.oidc_config_and_provider.oidc_endpoint_url
  #path                 = module.account_iam_resources.path
  path                 = var.path
}


module "rosa_cluster_hcp" {
  source = "terraform-redhat/rosa-hcp/rhcs//modules/rosa-cluster-hcp"
  #version = "1.6.9"

  cluster_name           = var.cluster_name
  operator_role_prefix   = var.cluster_name
  openshift_version      = var.openshift_version
  aws_billing_account_id = "604574367752"
  installer_role_arn     = module.account_iam_resources.account_roles_arn["HCP-ROSA-Installer"]
  support_role_arn       = module.account_iam_resources.account_roles_arn["HCP-ROSA-Support"]
  worker_role_arn        = module.account_iam_resources.account_roles_arn["HCP-ROSA-Worker"]
  oidc_config_id         = module.oidc_config_and_provider.oidc_config_id
  aws_subnet_ids         = local.rosa_aws_subnet_ids
  machine_cidr           = var.machine_cidr
  service_cidr           = var.service_cidr
  pod_cidr               = var.pod_cidr
  host_prefix            = var.host_prefix
  private                = var.private
  properties             = var.properties

  create_admin_user          = true
  admin_credentials_username = var.admin_credentials_username
  admin_credentials_password = random_string.random.result

  cluster_autoscaler_enabled         = var.cluster_autoscaler_enabled
  autoscaler_max_pod_grace_period    = var.autoscaler_max_pod_grace_period
  autoscaler_pod_priority_threshold  = var.autoscaler_pod_priority_threshold
  autoscaler_max_node_provision_time = var.autoscaler_max_node_provision_time
  autoscaler_max_nodes_total         = var.autoscaler_max_nodes_total

  wait_for_create_complete            = var.wait_for_create_complete
  wait_for_std_compute_nodes_complete = var.wait_for_std_compute_nodes_complete
  disable_waiting_in_destroy          = var.disable_waiting_in_destroy
  destroy_timeout                     = var.destroy_timeout
  upgrade_acknowledgements_for        = var.upgrade_acknowledgements_for
  

  
  replicas                                  = var.replicas
  compute_machine_type                      = var.compute_machine_type
  aws_availability_zones                    = var.aws_availability_zones
  aws_additional_compute_security_group_ids = var.aws_additional_compute_security_group_ids

}



module "rhcs_hcp_machine_pool" {
  #source   = "git::https://github.com/terraform-redhat/terraform-rhcs-rosa-hcp.git//modules/machine-pool?ref=release-1.6.9
  source   = "terraform-redhat/rosa-hcp/rhcs//modules/machine-pool"
  #version = "1.6.9"
  
  for_each = var.machine_pools

  #cluster_id                   = try(module.rosa_cluster_hcp.cluster_id, "dummy")
  #cluster_id = module.rosa_cluster_hcp.cluster_id != "" ? module.rosa_cluster_hcp.cluster_id : null
  cluster_id                   = (try(module.rosa_cluster_hcp.cluster_id, "") != "" ? module.rosa_cluster_hcp.cluster_id : null )
  name                         = each.value.name
  auto_repair                  = try(each.value.auto_repair, null)
  autoscaling                  = try(each.value.autoscaling, null)
  aws_node_pool                = each.value.aws_node_pool
  openshift_version            = try(each.value.openshift_version, null)
  tuning_configs               = try(each.value.tuning_configs, null)
  upgrade_acknowledgements_for = try(each.value.upgrade_acknowledgements_for, null)
  replicas                     = try(each.value.replicas, null)
  taints                       = try(each.value.taints, null)
  labels                       = try(each.value.labels, null)
  subnet_id                    = each.value.subnet_id
  kubelet_configs              = try(each.value.kubelet_configs, null)
  ignore_deletion_error        = try(each.value.ignore_deletion_error, var.ignore_machine_pools_deletion_error)
  
  depends_on = [
    module.rosa_cluster_hcp
  ]

}

module "htpasswd_idp" {
  source = "terraform-redhat/rosa-hcp/rhcs//modules/idp"
  #version = "1.6.9"

  cluster_id         = try(module.rosa_cluster_hcp.cluster_id, "dummy")
  name               = "htpasswd"
  idp_type           = "htpasswd"
  htpasswd_idp_users = [
    { username = "test-user", 
      password = "Some-Complicated-123-Password"
    }
  ]
}

# Attach worker node role
resource "aws_iam_role_policy_attachment" "rosa_ecr_role_iam_attachment" {
  count      = var.enable-ecr-role-nodes == true ? 1 : 0
  role       = "${var.cluster_name}-HCP-ROSA-Worker-Role"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  depends_on = [
    module.account_iam_resources
  ]
}

resource "aws_ec2_tag" "tag_private_subnets" {
  count       = length(var.private_aws_subnet_ids)
  resource_id = var.private_aws_subnet_ids[count.index]
  key         = "kubernetes.io/role/internal-elb"
  value       = ""
}

resource "random_string" "random" {
  length = 20
  special = false
  numeric = true
  min_numeric = 4
  min_lower   = 6
  min_upper   = 6
}


resource "time_sleep" "wait_60_seconds" {
  depends_on = [
    module.rosa_cluster_hcp
  ]

  create_duration = "60s"
}

resource "null_resource" "install-gitops" {
  provisioner "local-exec" {
    command = "bash ${path.module}/install-gitops.sh ${var.admin_credentials_username} ${random_string.random.result} ${module.rosa_cluster_hcp.cluster_api_url}"
  }
  depends_on = [time_sleep.wait_60_seconds]
}

