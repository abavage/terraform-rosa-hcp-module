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

  rosa_aws_subnet_ids = concat (
    var.public_aws_subnet_ids,
    var.private_aws_subnet_ids
  )

}