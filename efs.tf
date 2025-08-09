resource "aws_iam_policy" "rosa_efs_csi_policy" {
  
  name        = "${var.cluster_name}-rosa-efs-csi"
  path        = "/"
  description = "AWS EFS CSI Driver Policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elasticfilesystem:DescribeAccessPoints",
          "elasticfilesystem:DescribeFileSystems",
          "elasticfilesystem:DescribeMountTargets",
          "elasticfilesystem:TagResource",
          "ec2:DescribeAvailabilityZones"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "elasticfilesystem:CreateAccessPoint"
        ]
        Resource = "*"
        Condition = {
          StringLike = {
            "aws:RequestTag/efs.csi.aws.com/cluster" = "true"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "elasticfilesystem:DeleteAccessPoint",
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/efs.csi.aws.com/cluster" = "true"
          }
        }
      }
    ]
  })
  depends_on = [
    module.rosa_cluster_hcp
  ]
}

resource "aws_iam_role" "rosa_efs_csi_role" {

  name = "${var.cluster_name}-rosa-efs-csi-role"
  # permissions_boundary = local.permissions_boundary

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${module.oidc_config_and_provider.oidc_endpoint_url}"
        }
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${module.oidc_config_and_provider.oidc_endpoint_url}:sub" = [
              "system:serviceaccount:openshift-cluster-csi-drivers:aws-efs-csi-driver-operator",
              "system:serviceaccount:openshift-cluster-csi-drivers:aws-efs-csi-driver-controller-sa"
            ]
          }
        }
      }
    ]
  })
  depends_on = [
    module.rosa_cluster_hcp
  ]
}

resource "aws_iam_role_policy_attachment" "rosa_efs_csi_role_iam_attachment" {
  role       = aws_iam_role.rosa_efs_csi_role.name
  policy_arn = aws_iam_policy.rosa_efs_csi_policy.arn
  depends_on = [
    module.rosa_cluster_hcp
  ]
}

resource "aws_efs_file_system" "rosa_efs" {
  encrypted  = true
  tags = {
    Name = "${var.cluster_name}-rosa-efs"
  }
  depends_on = [
    module.rosa_cluster_hcp
  ]
}

data "aws_security_groups" "selected" {
  filter {
    name   = "tag:Name"
    values = ["${one(module.rosa_cluster_hcp[*].cluster_id)}-default-sg"]
  }
  depends_on = [
    module.rosa_cluster_hcp
  ]
}

# update the default sec group for the default machine pool nodes using a data lookup
resource "aws_vpc_security_group_ingress_rule" "enable_efs" {
  for_each = toset(var.aws_private_subnet_cidrs)

  security_group_id = data.aws_security_groups.selected.ids[0]
  cidr_ipv4         = each.value
  from_port         = 2049
  ip_protocol       = "tcp"
  to_port           = 2049
  depends_on = [
    resource.aws_efs_file_system.rosa_efs
  ]
  lifecycle {
    ignore_changes = [
      security_group_id
    ]
  }
}

# create a mount target in each subnet
resource "aws_efs_mount_target" "efs_mount_worker" {
  for_each = toset(var.private_aws_subnet_ids)

  file_system_id  = aws_efs_file_system.rosa_efs.id
  subnet_id       = each.value
  security_groups = [data.aws_security_groups.selected.ids[0]]
  lifecycle {
    ignore_changes = [
      security_groups
    ]
  }
  depends_on = [
    resource.aws_efs_file_system.rosa_efs
  ]
}
