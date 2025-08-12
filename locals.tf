locals {

  account_id = data.aws_caller_identity.current.id

  operator_role_prefix = var.cluster_name

  aws_zones = data.aws_availability_zones.available.names

  tags = {
    cluster_name = var.cluster_name
    region       = var.aws_region
    this         = "that"
    one          = "two"
    three        = "four"
  }

  rosa_aws_subnet_ids = concat(
    var.public_aws_subnet_ids,
    var.private_aws_subnet_ids
  )

  http_proxy  = "http://10.0.2.21:3128"
  https_proxy = "http://10.0.2.21:3128"
  no_proxy    = "10.0.0.0/16"


  cloudwatch_siem_role_iam_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.cluster_name}-seim-logging-cloudwatch-role"

  #default_workers_labels_json = var.default_workers_labels != null ? jsonencode(var.default_workers_labels) : "{}"
  #default_workers_labels_json = var.default_workers_labels != null ? (var.default_workers_labels) : "{}"

  #default_workers_labels_csv = var.default_workers_labels != null ? join(
  # ",",
  #  [for k, v in var.default_workers_labels : "${k}=\"${v}\""]
  #) : ""

  #default_workers_labels_csv = var.default_workers_labels != null ? format(
  #"--labels %s",
  #  join(
  #    ",",
  #    [for k, v in var.default_workers_labels : "${k}=${v}"]
  #  )
  #) : ""

  #default_workers_labels_flag = var.default_workers_labels != null ? format(
  #  "--labels '%s'",
  #  join(",", [for k, v in var.default_workers_labels : "${k}=${v}"])
  #) : ""

  default_workers_labels_csv = var.default_workers_labels != null ? join(
    ",",
    [for k, v in var.default_workers_labels : "${k}=${v}"]
  ) : ""


}