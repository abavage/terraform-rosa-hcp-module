resource "aws_sns_topic" "monitoring_sns_topic" {
  name = "${var.cluster_name}-rosa-monitoring-sns-topic"
  display_name = "${var.cluster_name}-rosa-monitoring-sns-topic"
  region = data.aws_region.current.region

  tags = merge(
    local.tags,
    {
      rosa-monitoring = "true",
      type    = "email"
    }
  )
}

resource "aws_sns_topic_subscription" "monitoring_sns_topic_subscription" {
  topic_arn = aws_sns_topic.monitoring_sns_topic.arn
  protocol  = "email"
  endpoint  = "abavage@redhat.com"
}

resource "aws_iam_policy" "rosa_monitoring_sns_policy" {

  name        = "${var.cluster_name}-rosa-monitoring-sns-topic"
  path        = "/"
  description = "ROSA Monitoring SNS Topic"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        #Resource = "arn:aws:sns:ap-southeast-2:281359555390:one-rosa-monitoring-sns-topic"
        Resource = "arn:aws:sns:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:${var.cluster_name}-rosa-monitoring-sns-topic"
        # arn:aws:sns:ap-southeast-2:data.aws_caller_identity.current.account_id:one-rosa-monitoring-sns-topic
      }
    ]
  })
  depends_on = [
    module.rosa_cluster_hcp
  ]
}

resource "aws_iam_role" "rosa_monitoring_sns_role" {

  name = "${var.cluster_name}-rosa-monitoring-sns-role"
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
              "system:serviceaccount:openshift-user-workload-monitoring:alertmanager-user-workload"
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

resource "aws_iam_role_policy_attachment" "rosa_monitoring_sns_attachment" {
  role       = aws_iam_role.rosa_monitoring_sns_role.name
  policy_arn = aws_iam_policy.rosa_monitoring_sns_policy.arn
  depends_on = [
    module.rosa_cluster_hcp
  ]
}

