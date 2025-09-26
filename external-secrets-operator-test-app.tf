#######################
#
# Example setup to for the "deployment: test-app" in "namespace: testapp" to source a secret from aws secrets manager via "serviceAccount: test-app"
#
#######################


resource "aws_secretsmanager_secret" "test_app_secrets" {
  name                    = "${var.cluster_name}-test-app-secrets"
  recovery_window_in_days = 0

  depends_on = [
    module.rosa_cluster_hcp
  ]
}

resource "aws_secretsmanager_secret_version" "test_app" {
  secret_id = aws_secretsmanager_secret.test_app_secrets.id
  secret_string = jsonencode({
    rosa_api_token    = var.RHCS_TOKEN
  })
  depends_on = [
    aws_secretsmanager_secret.test_app_secrets
  ]
}


resource "aws_iam_policy" "external_secret_store_policy_test_app" {

  name        = "${var.cluster_name}-external-secret-store-test-app"
  path        = "/"
  description = "External Secret Store test-app"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action" : [
          "secretsmanager:ListSecrets",
          "secretsmanager:BatchGetSecretValue"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ],
        "Resource": [
          "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:${var.cluster_name}-test-app-secrets*"
        ]
      }
    ]
  })
  depends_on = [
    module.rosa_cluster_hcp
  ]
}

resource "aws_iam_role" "external_secret_store_role_test_app" {

  name = "${var.cluster_name}-external-secret-store-test-app"
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
              "system:serviceaccount:test-app:test-app"
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

resource "aws_iam_role_policy_attachment" "external_secret_store_test_app_attachment" {
  role       = aws_iam_role.external_secret_store_role_test_app.name
  policy_arn = aws_iam_policy.external_secret_store_policy_test_app.arn
  depends_on = [
    module.rosa_cluster_hcp
  ]
}