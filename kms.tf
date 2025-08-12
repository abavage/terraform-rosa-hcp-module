resource "aws_kms_key" "ebs" {
  description             = "${var.cluster_name} kms key for ebs volumes"
  deletion_window_in_days = 10
  tags = merge(
    local.tags,
    {
      red-hat = "true"
      type    = "ebs"
    }
  )
}

resource "aws_kms_key" "etcd" {
  description             = "${var.cluster_name} kms key for etcd"
  deletion_window_in_days = 10
  tags = merge(
    local.tags,
    {
      red-hat = "true",
      type    = "etcd"
    }
  )
}