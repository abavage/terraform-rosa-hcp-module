resource "aws_iam_policy" "siem_logging_cloudwatch_policy" {
  name        = "${var.cluster_name}-siem-logging-cloudwatch-policy"
  path        = "/"
  description = "siem-logging-cloudwatch-policy"

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:PutRetentionPolicy"
        ],
        Resource : "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role" "seim_logging_cloudwatch_policy" {
  name = "${var.cluster_name}-seim-logging-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Principal : {
          Federated : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${module.oidc_config_and_provider.oidc_endpoint_url}"
        },
        Action : "sts:AssumeRoleWithWebIdentity",
        Condition : {
          StringEquals : {
            "${module.oidc_config_and_provider.oidc_endpoint_url}:sub" = [
              "system:serviceaccount:openshift-config-managed:cloudwatch-audit-exporter"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "seim_logging_cloudwatch_policy_attach_role" {
  role       = aws_iam_role.seim_logging_cloudwatch_policy.name
  policy_arn = aws_iam_policy.siem_logging_cloudwatch_policy.arn
}

resource "shell_script" "enable_siem_logging" {

  lifecycle_commands {
    create = templatefile(
      "./scripts/siem-logging.tftpl",
      {
        siem_role_arn = local.cloudwatch_siem_role_iam_arn
        cluster       = var.cluster_name
        enable        = true
        token         = var.RHCS_TOKEN
    })
    delete = templatefile(
      "./scripts/siem-logging.tftpl",
      {
        siem_role_arn = local.cloudwatch_siem_role_iam_arn
        cluster       = var.cluster_name
        enable        = false
        token         = var.RHCS_TOKEN
    })
  }
  environment           = {}
  sensitive_environment = {}
  depends_on = [
    module.rosa_cluster_hcp
  ]
}