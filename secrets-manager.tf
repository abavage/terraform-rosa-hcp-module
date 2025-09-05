resource "aws_secretsmanager_secret" "cluster_credentials" {
  name                    = "${var.cluster_name}-cluster-credentials"
  recovery_window_in_days = 0

  depends_on = [
    module.rosa_cluster_hcp
  ]
}

resource "aws_secretsmanager_secret_version" "secret" {
  secret_id = aws_secretsmanager_secret.cluster_credentials.id
  secret_string = jsonencode({
    username    = "${module.rosa_cluster_hcp.cluster_admin_username}",
    password    = "${random_string.random.result}",
    api_url     = "${module.rosa_cluster_hcp.cluster_api_url}",
    console_url = "${module.rosa_cluster_hcp.cluster_console_url}"
  })
  depends_on = [
    aws_secretsmanager_secret.cluster_credentials
  ]
}

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