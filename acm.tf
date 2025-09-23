resource "aws_s3_bucket" "acm_observability" {
  bucket = "${var.cluster_name}-acm-observability"
  force_destroy = true

  tags = {
    Name        = "${var.cluster_name}-acm-observability"
  }
}

resource "aws_iam_policy" "acm_observability" {

  name        = "${var.cluster_name}-acm-observability"
  path        = "/"
  description = "ECR Secret Operator"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
            "s3:ListBucket",
            "s3:GetObject",
            "s3:DeleteObject",
            "s3:PutObject",
            "s3:PutObjectAcl",
            "s3:CreateBucket",
            "s3:DeleteBucket"
        ]
        Resource = [
            "arn:aws:s3:::${var.cluster_name}-acm-observability/*",
            "arn:aws:s3:::${var.cluster_name}-acm-observability"

        ]
      }
    ]
  })
  depends_on = [
    module.rosa_cluster_hcp
  ]
}

resource "aws_iam_role" "acm_observability" {

  name = "${var.cluster_name}-acm_observability"
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
                "system:serviceaccount:open-cluster-management-observability:observability-thanos-query",
                "system:serviceaccount:open-cluster-management-observability:observability-thanos-store-shard",
                "system:serviceaccount:open-cluster-management-observability:observability-thanos-compact",
                "system:serviceaccount:open-cluster-management-observability:observability-thanos-rule",
                "system:serviceaccount:open-cluster-management-observability:observability-thanos-receive"
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

resource "aws_iam_role_policy_attachment" "acm_observability_attachment" {
  role       = aws_iam_role.acm_observability.name
  policy_arn = aws_iam_policy.acm_observability.arn
  depends_on = [
    module.rosa_cluster_hcp
  ]
}
