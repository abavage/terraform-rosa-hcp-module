data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_efs_file_system" "fsid" {
  file_system_id = aws_efs_file_system.rosa_efs.id

  depends_on = [
    aws_efs_file_system.rosa_efs
  ]
}
data "aws_security_group" "selected" {
  filter {
    name   = "tag:Name"
    values = ["${one(module.rosa_cluster_hcp[*].cluster_id)}-default-sg"]
  }
  depends_on = [
    module.rosa_cluster_hcp
  ]
}

#data "aws_security_group" "selected_tag" {
#  filter {
#    name   = "tag:Name"
#    values = ["${one(module.rosa_cluster_hcp[*].cluster_id)}-default-sg"]
#  }
#  depends_on = [
#    module.rosa_cluster_hcp
#  ]
#}