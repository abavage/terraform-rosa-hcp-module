resource "aws_iam_role" "rosa_karpenter_controller_role" {

  name = "rosa-karpenter-controller-role-${var.cluster_name}"
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
              "system:serviceaccount:kube-system:karpenter"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "rosa_karpenter_controller_policy" {

  name        = "rosa-karpenter-controller-policy-${var.cluster_name}"
  path        = "/"
  description = "rosa-karpenter-controller-policy-${var.cluster_name}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
    {
      "Sid": "ReadPermissions",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeCapacityReservations",
        "ec2:DescribeImages",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceTypeOfferings",
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeLaunchTemplates",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSnapshots",
        "ec2:DescribeSpotPriceHistory",
        "ec2:DescribeSubnets",
        "ec2:DescribeVpcs"
      ],
      "Resource": "*"
    },
    {
      "Sid": "PricingReadActions",
      "Effect": "Allow",
      "Action": [
        "pricing:GetProducts"
      ],
      "Resource": "*"
    },
    {
      "Sid": "KMSPermissions",
      "Effect": "Allow",
      "Action": [
        "kms:DescribeKey",
        "kms:Decrypt",
        "kms:ReEncryptFrom",
        "kms:ReEncryptTo",
        "kms:GenerateDataKeyWithoutPlaintext"
      ],
      "Resource": "arn:aws:kms:*:*:key/*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/red-hat": "true"
        },
        "StringLike": {
          "kms:ViaService": "ec2.*.amazonaws.com"
        }
      }
    },
    {
      "Sid": "KMSGrantPermissions",
      "Effect": "Allow",
      "Action": [
        "kms:CreateGrant"
      ],
      "Resource": "arn:aws:kms:*:*:key/*",
      "Condition": {
        "Bool": {
          "kms:GrantIsForAWSResource": true
        },
        "StringLike": {
          "kms:ViaService": "ec2.*.amazonaws.com"
        }
      }
    },
    {
      "Sid": "CreateEC2Resources",
      "Effect": "Allow",
      "Action": [
        "ec2:RunInstances",
        "ec2:CreateFleet"
      ],
      "Resource": [
        "arn:aws:ec2:*:*:security-group/*",
        "arn:aws:ec2:*:*:subnet/*",
        "arn:aws:ec2:*:*:capacity-reservation/*"
      ]
    },
    {
      "Sid": "CreateEC2ResourcesWithApprovedAMIs",
      "Effect": "Allow",
      "Action": [
        "ec2:RunInstances",
        "ec2:CreateFleet"
      ],
      "Resource": "arn:aws:ec2:*::image/*",
      "Condition": {
        "StringEquals": {
          "ec2:Owner": [
            "531415883065",
            "251351625822",
            "210686502322"
          ]
        }
      }
    },
    {
      "Sid": "CreateEC2ResourcesWithTags",
      "Effect": "Allow",
      "Action": [
        "ec2:RunInstances",
        "ec2:CreateFleet",
        "ec2:CreateLaunchTemplate"
      ],
      "Resource": [
        "arn:aws:ec2:*:*:fleet/*",
        "arn:aws:ec2:*:*:instance/*",
        "arn:aws:ec2:*:*:volume/*",
        "arn:aws:ec2:*:*:network-interface/*",
        "arn:aws:ec2:*:*:launch-template/*",
        "arn:aws:ec2:*:*:spot-instances-request/*"
      ],
      "Condition": {
        "StringEquals": {
          "aws:RequestTag/red-hat-managed": "true"
        }
      }
    },
    {
      "Sid": "CreateEC2ResourcesLaunchTemplate",
      "Effect": "Allow",
      "Action": [
        "ec2:RunInstances",
        "ec2:CreateFleet"
      ],
      "Resource": "arn:aws:ec2:*:*:launch-template/*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/red-hat-managed": "true"
        }
      }
    },
    {
      "Sid": "CreateTagsOnResources",
      "Effect": "Allow",
      "Action": [
        "ec2:CreateTags"
      ],
      "Resource": [
        "arn:aws:ec2:*:*:fleet/*",
        "arn:aws:ec2:*:*:instance/*",
        "arn:aws:ec2:*:*:volume/*",
        "arn:aws:ec2:*:*:network-interface/*",
        "arn:aws:ec2:*:*:launch-template/*",
        "arn:aws:ec2:*:*:spot-instances-request/*"
      ],
      "Condition": {
        "StringEquals": {
          "ec2:CreateAction": [
            "RunInstances",
            "CreateFleet",
            "CreateLaunchTemplate"
          ],
          "aws:RequestTag/red-hat-managed": "true"
        }
      }
    },
    {
      "Sid": "ManageTagsOnManagedResources",
      "Effect": "Allow",
      "Action": [
        "ec2:CreateTags"
      ],
      "Resource": "arn:aws:ec2:*:*:instance/*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/red-hat-managed": "true"
        }
      }
    },
    {
      "Sid": "TerminateManagedResources",
      "Effect": "Allow",
      "Action": [
        "ec2:TerminateInstances",
        "ec2:DeleteLaunchTemplate"
      ],
      "Resource": [
        "arn:aws:ec2:*:*:instance/*",
        "arn:aws:ec2:*:*:launch-template/*"
      ],
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/red-hat-managed": "true"
        }
      }
    },
    {
      "Sid": "PassInstanceRole",
      "Effect": "Allow",
      "Action": [
        "iam:PassRole"
      ],
      "Resource": "arn:aws:iam::*:role/*-ROSA-Worker-Role",
      "Condition": {
        "StringEquals": {
          "iam:PassedToService": [
            "ec2.amazonaws.com"
          ]
        }
      }
    },
    {
      "Sid": "ManageInstanceProfiles",
      "Effect": "Allow",
      "Action": [
        "iam:AddRoleToInstanceProfile",
        "iam:RemoveRoleFromInstanceProfile",
        "iam:DeleteInstanceProfile"
      ],
      "Resource": [
        "arn:aws:iam::*:instance-profile/rosa-service-managed-*"
      ]
    },
    {
      "Sid": "CreateInstanceProfiles",
      "Effect": "Allow",
      "Action": [
        "iam:CreateInstanceProfile",
        "iam:TagInstanceProfile"
      ],
      "Resource": [
        "arn:aws:iam::*:instance-profile/rosa-service-managed-*"
      ],
      "Condition": {
        "StringEquals": {
          "aws:RequestTag/red-hat-managed": "true"
        }
      }
    },
    {
      "Sid": "ReadInstanceProfiles",
      "Effect": "Allow",
      "Action": [
        "iam:GetInstanceProfile",
        "iam:ListInstanceProfiles"
      ],
      "Resource": "*"
    } 
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rosa_karpenter_controller_attachment" {
  role       = aws_iam_role.rosa_karpenter_controller_role.name
  policy_arn = aws_iam_policy.rosa_karpenter_controller_policy.arn
}


resource "aws_ec2_tag" "karpenter_tag_security_group" {
  resource_id = data.aws_security_group.selected.id
  key         = "karpenter.sh/discovery"
  value       = module.rosa_cluster_hcp.cluster_id
  
  depends_on = [
    module.rosa_cluster_hcp
  ]
}

resource "aws_ec2_tag" "karpenter_tag_private_subnets" {
  count       = length(var.private_aws_subnet_ids)
  resource_id = var.private_aws_subnet_ids[count.index]
  key         = "karpenter.sh/discovery"
  value       = module.rosa_cluster_hcp.cluster_id
  
  depends_on = [
    module.rosa_cluster_hcp
  ]
}


output "sgs" {
  value = data.aws_security_group.selected
}