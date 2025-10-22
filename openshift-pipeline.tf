resource "aws_s3_bucket" "openshift_pipeline_image_builds" {
  bucket = "${var.cluster_name}-openshift-pipeline-image-builds"
  force_destroy = true

  tags = {
    Name        = "${var.cluster_name}-openshift-pipeline-image-builds"
  }
}

resource "aws_iam_policy" "openshift_pipeline_image_builds" {

  name        = "${var.cluster_name}-openshift-pipeline-image-builds"
  path        = "/"
  description = "openshift-pipeline-image-builds"

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
            "s3:PutObjectAcl"
        ]
        Resource = [
            "arn:aws:s3:::${var.cluster_name}-openshift-pipeline-image-builds/*",
            "arn:aws:s3:::${var.cluster_name}-openshift-pipeline-image-builds"

        ]
      }
    ]
  })
  depends_on = [
    module.rosa_cluster_hcp
  ]
}

resource "aws_iam_role" "openshift_pipeline_image_builds" {

  name = "${var.cluster_name}-openshift-pipeline-image-builds"
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
                "system:serviceaccount:image-builds:pipeline"
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

resource "aws_iam_role_policy_attachment" "openshift_pipeline_image_builds_attachment" {
  role       = aws_iam_role.openshift_pipeline_image_builds.name
  policy_arn = aws_iam_policy.openshift_pipeline_image_builds.arn
  depends_on = [
    module.rosa_cluster_hcp
  ]
}
