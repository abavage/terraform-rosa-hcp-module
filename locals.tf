locals {
  
  account_id = data.aws_caller_identity.current.id

  operator_role_prefix = var.cluster_name

  aws_zones = data.aws_availability_zones.available.names

  tags = {
    cluster_name = var.cluster_name
    region       = "ap-southeast-2"
    this         = "that"
    one          = "one"
    two          = "two"
  }

  default_machine_pools_replicas = 3
  default_machine_pools_instance_type = "m5.xlarge"


}