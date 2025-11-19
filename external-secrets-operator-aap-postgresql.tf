#######################
#
# framework to create aws secrets manager secret, IAM policy / trust policy. 
# For "project: aap", "serviceAccount: aws-secret-store", "secret: external-postgres-configuration "
#
#######################


resource "aws_secretsmanager_secret" "aap_postgresql_database" {
  name                    = "${var.cluster_name}-aap-postgresql-database"
  recovery_window_in_days = 0

  depends_on = [
    module.rosa_cluster_hcp
  ]
}

resource "aws_secretsmanager_secret_version" "aap_postgresql_database" {
  secret_id = aws_secretsmanager_secret.aap_postgresql_database.id
  secret_string = jsonencode({
    host              = var.postgresql_host,
    port              = var.postgresql_port,
    database          = var.postgresql_database,
    username          = var.postgresql_username,
    password          = var.postgresql_password,
    sslmode           = var.postgresql_sslmode,
    type              = var.postgresql_type
  })
  depends_on = [
    aws_secretsmanager_secret.aap_postgresql_database
  ]
}


resource "aws_iam_policy" "aap_postgresql_database" {

  name        = "${var.cluster_name}-aap-postgresql-database"
  path        = "/"
  description = "External Secret Store aap-postgresql-database"

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
          "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:${var.cluster_name}-aap-postgresql-database*"
        ]
      }
    ]
  })
  depends_on = [
    module.rosa_cluster_hcp
  ]
}

resource "aws_iam_role" "aap_postgresql_database" {

  name = "${var.cluster_name}-aap-postgresql-database"
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
              "system:serviceaccount:aap:aws-secret-manager"
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

resource "aws_iam_role_policy_attachment" "aap_postgresql_databas_attachment" {
  role       = aws_iam_role.aap_postgresql_database.name
  policy_arn = aws_iam_policy.aap_postgresql_database.arn
  depends_on = [
    module.rosa_cluster_hcp
  ]
}