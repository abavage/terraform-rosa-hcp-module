module "rosa_cluster_hcp" {
  source = "terraform-redhat/rosa-hcp/rhcs//modules/rosa-cluster-hcp"
  version = "1.6.9"

  cluster_name           = "my-cluster"
  operator_role_prefix   = "my-operators"
  openshift_version      = "4.14.24"
  installer_role_arn     = "arn:aws:iam::012345678912:role/ManagedOpenShift-HCP-ROSA-Installer-Role"
  support_role_arn       = "arn:aws:iam::012345678912:role/ManagedOpenShift-HCP-ROSA-Support-Role"
  worker_role_arn        = "arn:aws:iam::012345678912:role/ManagedOpenShift-HCP-ROSA-Worker-Role"
  oidc_config_id         = "oidc-config-123"
  aws_subnet_ids         = ["subnet-1","subnet-2"]
  machine_cidr           = "10.0.0.0/16"
  service_cidr           = "172.30.0.0/16"
  pod_cidr               = "10.128.0.0/14"
  host_prefix            = "23"
  replicas               = 2
  compute_machine_type   = "m5.xlarge"
  aws_availability_zones = ["us-west-2a"]
}



module "rhcs_hcp_machine_pool" {
  #source   = "git::https://github.com/terraform-redhat/terraform-rhcs-rosa-hcp.git//modules/machine-pool"
  source   = "terraform-redhat/rosa-hcp/rhcs//modules/machine-pool"
  version = "1.6.9"
  for_each = var.machine_pools

  cluster_id                   = try(module.rosa-hcp.cluster_id, "dummy")
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
  ignore_deletion_error        = try(each.value.ignore_deletion_error, false)
}


module "htpasswd_idp" {
  source = "terraform-redhat/rosa-hcp/rhcs//modules/idp"
  version = "1.6.9"

  cluster_id         = module.rosa-hcp.cluster_id
  name               = "htpasswd-idp"
  idp_type           = "htpasswd"
  htpasswd_idp_users = jsonencode( 
    [
      { username = "some-user", 
        password = "Some-Complicated-123-Password"
      }
    ]
  )
}
