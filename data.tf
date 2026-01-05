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