resource "aws_iam_policy" "cert_manager_operator" {

  name        = "${var.cluster_name}-cert-manager-operator"
  path        = "/"
  description = "Certificate Manager Operator"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : "route53:GetChange",
        "Resource" : "arn:aws:route53:::change/*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets"
        ],
        "Resource" : "arn:aws:route53:::hostedzone/*",
        "Condition" : {
          "ForAllValues:StringEquals" : {
            "route53:ChangeResourceRecordSetsRecordTypes" : ["TXT"]
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : "route53:ListHostedZonesByName",
        "Resource" : "*"
      }
    ]
  })
  depends_on = [
    module.rosa_cluster_hcp
  ]
}

resource "aws_iam_role" "cert_manager_operator" {

  name = "${var.cluster_name}-cert-manager-operator"
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
              "system:serviceaccount:cert-manager:cert-manager"
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

resource "aws_iam_role_policy_attachment" "cert_manager_operator_attachment" {
  role       = aws_iam_role.cert_manager_operator.name
  policy_arn = aws_iam_policy.cert_manager_operator.arn
  depends_on = [
    module.rosa_cluster_hcp
  ]
}
