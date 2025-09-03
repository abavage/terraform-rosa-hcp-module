resource "aws_iam_policy" "external_secret_operator_policy" {

  name        = "${var.cluster_name}-external-secret-operator"
  path        = "/"
  description = "External Secret Operator"

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
          "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:${var.cluster_name}*"
        ]
      }
    ]
  })
  depends_on = [
    module.rosa_cluster_hcp
  ]
}

resource "aws_iam_role" "external_secret_operator_role" {

  name = "${var.cluster_name}-external-secret-operator"
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
              "system:serviceaccount:external-secrets-operator:external-secrets-operator-controller-manager"
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

resource "aws_iam_role_policy_attachment" "external_secret_operator_attachment" {
  role       = aws_iam_role.external_secret_operator_role.name
  policy_arn = aws_iam_policy.external_secret_operator_policy.arn
  depends_on = [
    module.rosa_cluster_hcp
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
          "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:${var.cluster_name}*"
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