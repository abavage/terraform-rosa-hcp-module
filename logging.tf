resource "aws_iam_policy" "logging_cloudwatch_policy" {
  name        = "${var.cluster_name}-logging-cloudwatch-policy"
  path        = "/"
  description = "siem-logging-cloudwatch-policy"

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        "Sid" : "allCWloggingOptions",
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
      },
      {
        "Sid" : "additionalforCWagent",
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeTags",
          "ec2:DescribeVolumes"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role" "logging_cloudwatch_policy" {
  name = "${var.cluster_name}-logging-cloudwatch-role"

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
              "system:serviceaccount:openshift-logging:logcollector",
              "system:serviceaccount:amazon-cloudwatch:cloudwatch-agent"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "seim_logging_cloudwatch_policy_attach_role" {
  role       = aws_iam_role.logging_cloudwatch_policy.name
  policy_arn = aws_iam_policy.logging_cloudwatch_policy.arn
}

resource "shell_script" "enable_logging" {
  lifecycle_commands {
    create = "${path.module}/scripts/logging.sh"
    delete = "${path.module}/scripts/no-operation-delete.sh"
  }

  environment = {
    logging_role_arn = local.cloudwatch_role_iam_arn
    cluster          = var.cluster_name
  }

  sensitive_environment = {
    token = var.RHCS_TOKEN
  }

  #triggers = {
  #  always_run = timestamp()
  #}

  depends_on = [
    module.rosa_cluster_hcp
  ]

}


## dedicated logging

resource "aws_iam_policy" "cluster_log_forwarder_cloudwatch_policy" {
  name        = "${var.cluster_name}-cluster-log-forwarder-cloudwatch-policy"
  path        = "/"
  description = "cluster-log-forwarder-cloudwatch-policy"

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

resource "aws_iam_role" "cluster_log_forwarder_cloudwatch_role" {
  name = "CustomerLogDistribution-${var.cluster_name}-cluster-log-forwarder-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Principal : {
          "AWS" : "arn:aws:iam::859037107838:role/ROSA-CentralLogDistributionRole-241c1a86"
        },
        Action : "sts:AssumeRole",
        Condition : {
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_log_forwarder_cloudwatch_policy_attach_role" {
  role       = aws_iam_role.cluster_log_forwarder_cloudwatch_role.name
  policy_arn = aws_iam_policy.cluster_log_forwarder_cloudwatch_policy.arn
}

