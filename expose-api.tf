data "aws_security_groups" "vpc_endpoint_default" {
  filter {
    name   = "tag:Name"
    values = ["${one(module.rosa_cluster_hcp[*].cluster_id)}-vpce-private-router"]
  }
  depends_on = [
    module.rosa_cluster_hcp
  ]
}

resource "aws_vpc_security_group_ingress_rule" "expose_api_sg" {

  security_group_id = data.aws_security_groups.vpc_endpoint_default.ids[0]
  ## Dummy CIDR shoudkl be replaced with customers required source CIDR block (s) to acccess private cluster
  cidr_ipv4   = "10.0.0.0/32"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
  lifecycle {
    ignore_changes = [
      security_group_id
    ]
  }
  depends_on = [
    module.rosa_cluster_hcp
  ]
}