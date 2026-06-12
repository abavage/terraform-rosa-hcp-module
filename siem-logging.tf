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

resource "aws_iam_role" "siem_logging_cloudwatch_policy" {
  name = "${var.cluster_name}-siem-logging-cloudwatch-role"

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
              "system:serviceaccount:openshift-config-managed:cloudwatch-audit-exporter",
              "system:serviceaccount:openshift-logging:logcollector"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "seim_logging_cloudwatch_policy_attach_role" {
  role       = aws_iam_role.siem_logging_cloudwatch_policy.name
  policy_arn = aws_iam_policy.siem_logging_cloudwatch_policy.arn
}

resource "shell_script" "enable_siem_logging" {
  lifecycle_commands {
    create = "${path.module}/scripts/siem-logging.sh"
    delete = "${path.module}/scripts/no-operation-delete.sh"
  }

  environment = {
    siem_role_arn = local.cloudwatch_siem_role_iam_arn
    cluster       = var.cluster_name
  }

  sensitive_environment = {
    token         = var.RHCS_TOKEN
  }

  #triggers = {
  #  always_run = timestamp()
  #}

  depends_on = [
    module.rosa_cluster_hcp
  ]

}





## dedicated logging

resource "aws_iam_policy" "dedicated_logging_cloudwatch_policy" {
  name        = "${var.cluster_name}-dedicated-logging-cloudwatch-policy"
  path        = "/"
  description = "dedicated-logging-cloudwatch-policy"

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

resource "aws_iam_role" "dedicated_logging_cloudwatch_policy" {
  name = "CustomerLogDistribution-${var.cluster_name}-dedicated-logging-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Principal : {
          "AWS": "arn:aws:iam::859037107838:role/ROSA-CentralLogDistributionRole-241c1a86"
        },
        Action : "sts:AssumeRole",
        Condition : {
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dedicated_logging_cloudwatch_policy_attach_role" {
  role       = aws_iam_role.dedicated_logging_cloudwatch_policy.name
  policy_arn = aws_iam_policy.dedicated_logging_cloudwatch_policy.arn
}

