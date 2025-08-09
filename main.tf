##############################################################
# Account roles includes IAM roles and IAM policies
##############################################################

module "account_iam_resources" {
  source = "git::https://github.com/terraform-redhat/terraform-rhcs-rosa-hcp.git//modules/account-iam-resources"
  
  account_role_prefix  = var.cluster_name
  path                 = var.path

}

############################
# OIDC config and provider
############################
module "oidc_config_and_provider" {
  source = "git::https://github.com/terraform-redhat/terraform-rhcs-rosa-hcp.git//modules/oidc-config-and-provider"
 
}


############################
# operator roles
############################
module "operator_roles" {
  source = "git::https://github.com/terraform-redhat/terraform-rhcs-rosa-hcp.git//modules/operator-roles"
  
  operator_role_prefix = var.cluster_name
  oidc_endpoint_url    = module.oidc_config_and_provider.oidc_endpoint_url
  path                 = var.path
  
}

############################
# ROSA STS cluster
############################
module "rosa_cluster_hcp" {
  source = "git::https://github.com/terraform-redhat/terraform-rhcs-rosa-hcp.git//modules/rosa-cluster-hcp"

  cluster_name             = var.cluster_name
  #operator_role_prefix     = var.cluster_name
  operator_role_prefix     = module.operator_roles.operator_role_prefix
  openshift_version        = var.openshift_version
  installer_role_arn       = module.account_iam_resources.account_roles_arn["HCP-ROSA-Installer"]
  support_role_arn         = module.account_iam_resources.account_roles_arn["HCP-ROSA-Support"]
  worker_role_arn          = module.account_iam_resources.account_roles_arn["HCP-ROSA-Worker"]
  oidc_config_id           = module.oidc_config_and_provider.oidc_config_id
  aws_subnet_ids           = local.rosa_aws_subnet_ids
  machine_cidr             = var.machine_cidr
  service_cidr             = var.service_cidr
  pod_cidr                 = var.pod_cidr
  host_prefix              = var.host_prefix
  private                  = var.private
  tags                     = local.tags
  properties               = var.properties
  etcd_encryption          = var.etcd_encryption
  #etcd_kms_key_arn         = var.etcd_kms_key_arn
  etcd_kms_key_arn         = resource.aws_kms_key.etcd.arn 
  #kms_key_arn              = var.kms_key_arn
  kms_key_arn              = resource.aws_kms_key.ebs.arn 
  aws_billing_account_id   = "604574367752"
  ec2_metadata_http_tokens = var.ec2_metadata_http_tokens

  ########
  # Cluster Admin User
  ########  
  create_admin_user          = var.create_admin_user
  admin_credentials_username = var.admin_credentials_username
  admin_credentials_password = random_string.random.result

  ########
  # Flags
  ########
  wait_for_create_complete            = var.wait_for_create_complete
  wait_for_std_compute_nodes_complete = var.wait_for_std_compute_nodes_complete
  disable_waiting_in_destroy          = var.disable_waiting_in_destroy
  destroy_timeout                     = var.destroy_timeout
  upgrade_acknowledgements_for        = var.upgrade_acknowledgements_for

  #######################
  # Default Machine Pool
  #######################

  replicas                                  = var.replicas
  compute_machine_type                      = var.compute_machine_type
  aws_availability_zones                    = var.aws_availability_zones
  aws_additional_compute_security_group_ids = var.aws_additional_compute_security_group_ids

  ########
  # Proxy 
  ########
  http_proxy              = local.http_proxy
  https_proxy             = local.https_proxy
  no_proxy                = local.no_proxy
  additional_trust_bundle = var.additional_trust_bundle

  #############
  # Autoscaler 
  #############
  cluster_autoscaler_enabled         = var.cluster_autoscaler_enabled
  autoscaler_max_pod_grace_period    = var.autoscaler_max_pod_grace_period
  autoscaler_pod_priority_threshold  = var.autoscaler_pod_priority_threshold
  autoscaler_max_node_provision_time = var.autoscaler_max_node_provision_time
  autoscaler_max_nodes_total         = var.autoscaler_max_nodes_total

  ##################
  # default_ingress 
  ##################
  default_ingress_listening_method = var.default_ingress_listening_method != "" ? (
    var.default_ingress_listening_method) : (
    var.private ? "internal" : "external"
  )
  #depends_on = [
  #  module.account_iam_resources,
  #  module.oidc_config_and_provider,
  #  module.operator_roles
  #]  
}

######################################
# Multiple Machine Pools Generic block
######################################

module "rhcs_hcp_machine_pool" {
  source = "git::https://github.com/terraform-redhat/terraform-rhcs-rosa-hcp.git//modules/machine-pool"
  for_each = var.machine_pools

  cluster_id                   = module.rosa_cluster_hcp.cluster_id
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
}

###########################################
# Multiple Identity Providers Generic block
###########################################

#module "rhcs_identity_provider" {
#  source   = "git::https://github.com/terraform-redhat/terraform-rhcs-rosa-hcp.git//modules/idp"
#  for_each = var.identity_providers

#  cluster_id                            = module.rosa_cluster_hcp.cluster_id
#  name                                  = each.value.name
#  idp_type                              = each.value.idp_type
#  mapping_method                        = try(each.value.mapping_method, null)
#  github_idp_client_id                  = try(each.value.github_idp_client_id, null)
#  github_idp_client_secret              = try(each.value.github_idp_client_secret, null)
#  github_idp_ca                         = try(each.value.github_idp_ca, null)
#  github_idp_hostname                   = try(each.value.github_idp_hostname, null)
#  github_idp_organizations              = try(jsondecode(each.value.github_idp_organizations), null)
#  github_idp_teams                      = try(jsondecode(each.value.github_idp_teams), null)
#  gitlab_idp_client_id                  = try(each.value.gitlab_idp_client_id, null)
#  gitlab_idp_client_secret              = try(each.value.gitlab_idp_client_secret, null)
#  gitlab_idp_url                        = try(each.value.gitlab_idp_url, null)
#  gitlab_idp_ca                         = try(each.value.gitlab_idp_ca, null)
#  google_idp_client_id                  = try(each.value.google_idp_client_id, null)
#  google_idp_client_secret              = try(each.value.google_idp_client_secret, null)
#  google_idp_hosted_domain              = try(each.value.google_idp_hosted_domain, null)
#  htpasswd_idp_users                    = try(jsondecode(each.value.htpasswd_idp_users), null)
#  ldap_idp_bind_dn                      = try(each.value.ldap_idp_bind_dn, null)
#  ldap_idp_bind_password                = try(each.value.ldap_idp_bind_password, null)
#  ldap_idp_ca                           = try(each.value.ldap_idp_ca, null)
#  ldap_idp_insecure                     = try(each.value.ldap_idp_insecure, null)
#  ldap_idp_url                          = try(each.value.ldap_idp_url, null)
#  ldap_idp_emails                       = try(jsondecode(each.value.ldap_idp_emails), null)
#  ldap_idp_ids                          = try(jsondecode(each.value.ldap_idp_ids), null)
#  ldap_idp_names                        = try(jsondecode(each.value.ldap_idp_names), null)
#  ldap_idp_preferred_usernames          = try(jsondecode(each.value.ldap_idp_preferred_usernames), null)
#  openid_idp_ca                         = try(each.value.openid_idp_ca, null)
#  openid_idp_claims_email               = try(jsondecode(each.value.openid_idp_claims_email), null)
#  openid_idp_claims_groups              = try(jsondecode(each.value.openid_idp_claims_groups), null)
#  openid_idp_claims_name                = try(jsondecode(each.value.openid_idp_claims_name), null)
#  openid_idp_claims_preferred_username  = try(jsondecode(each.value.openid_idp_claims_preferred_username), null)
#  openid_idp_client_id                  = try(each.value.openid_idp_client_id, null)
#  openid_idp_client_secret              = try(each.value.openid_idp_client_secret, null)
#  openid_idp_extra_scopes               = try(jsondecode(each.value.openid_idp_extra_scopes), null)
#  openid_idp_extra_authorize_parameters = try(jsondecode(each.value.openid_idp_extra_authorize_parameters), null)
#  openid_idp_issuer                     = try(each.value.openid_idp_issuer, null)
#}

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

######################################
# Multiple Kubelet Configs block
######################################
#module "rhcs_hcp_kubelet_configs" {
#  source   = "./modules/kubelet-configs"
#  for_each = var.kubelet_configs

#  cluster_id     = module.rosa_cluster_hcp.cluster_id
#  name           = each.value.name
#  pod_pids_limit = each.value.pod_pids_limit
#}
