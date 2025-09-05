## ebs kms key
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

## etcd kms key
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

## efs kms key
resource "aws_kms_key" "efs" {
  description             = "${var.cluster_name} kms key for efs"
  deletion_window_in_days = 10
  tags = merge(
    local.tags,
    {
      red-hat = "true",
      type    = "efs"
    }
  )
}


## policy for ebs kms keys on a custom storageClass gp3-csi-kms, io2-csi-kms & efs-csi-kms
resource "aws_iam_policy" "rosa_kms_csi_policy_iam" {
  name        = "${var.cluster_name}-rosa-kms-csi"
  path        = "/"
  description = "AWS EBS CSI Driver Policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:GenerateDataKeyWithoutPlainText",
          "kms:DescribeKey"
        ]
        Resource = [
          "${resource.aws_kms_key.ebs.arn}",
          "${resource.aws_kms_key.efs.arn}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:RevokeGrant",
          "kms:CreateGrant",
          "kms:ListGrants"
        ]
        Resource = [
          "${resource.aws_kms_key.ebs.arn}",
          "${resource.aws_kms_key.efs.arn}"
        ]
      }
    ]
  })
}

## attach aws_iam_policy.rosa_kms_csi_policy_iam policy to exisitng operator role
resource "aws_iam_role_policy_attachment" "rosa_kms_csi_ebs_role_iam_attachment" {
  role       = "${var.cluster_name}-openshift-cluster-csi-drivers-ebs-cloud-credentials"
  policy_arn = aws_iam_policy.rosa_kms_csi_policy_iam.arn
  depends_on = [
    module.operator_roles,
    aws_iam_policy.rosa_kms_csi_policy_iam
  ]
}