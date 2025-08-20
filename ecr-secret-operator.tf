resource "aws_iam_policy" "ecr_secret_operator_policy" {

  name        = "${var.cluster_name}-ecr-secret-operator"
  path        = "/"
  description = "ECR Secret Operator"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
        ]
        Resource = "*"
      }
    ]
  })
  depends_on = [
    module.rosa_cluster_hcp
  ]
}

resource "aws_iam_role" "ecr_secret_operator_role" {

  name = "${var.cluster_name}-ecr-secret-operator"
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
              "system:serviceaccount:ecr-secret-operator:ecr-secret-operator-controller-manager"
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

resource "aws_iam_role_policy_attachment" "ecr_secret_operator_attachment" {
  role       = aws_iam_role.ecr_secret_operator_role.name
  policy_arn = aws_iam_policy.ecr_secret_operator_policy.arn
  depends_on = [
    module.rosa_cluster_hcp
  ]
}
