locals {

  account_id = data.aws_caller_identity.current.id

  operator_role_prefix = var.cluster_name

  aws_zones = data.aws_availability_zones.available.names

  tags = {
    cluster_name = var.cluster_name
    region       = var.aws_region
    this         = "that"
    one          = "two"
    three        = "four"
  }

  rosa_aws_subnet_ids = concat(
    var.public_aws_subnet_ids,
    var.private_aws_subnet_ids
  )

  http_proxy  = "http://10.0.2.21:3128"
  https_proxy = "http://10.0.2.21:3128"
  no_proxy    = "10.0.0.0/16"


  cloudwatch_siem_role_iam_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.cluster_name}-seim-logging-cloudwatch-role"


  default_workers_labels_csv = var.default_workers_labels != null ? join(
    ",",
    [for k, v in var.default_workers_labels : "${k}=${v}"]
  ) : ""

  identity_providers = {
    http = {
      idp_type = "htpasswd"
      name     = "htpasswd"
      htpasswd_idp_users = [
        {
          username = "bob"
          password = "SuperComplicated.Passwrod123"
        }
      ]
    }
    openid-idp = {
      name                                 = "openid-idp"
      idp_type                             = "openid"
      #openid_idp_ca                        = ""
      openid_idp_claims_email             = ["email"] # email
      #openid_idp_claims_groups            = ["groups"]
      openid_idp_claims_name              = ["name"] # name
      openid_idp_claims_preferred_username = ["preferred_username"] # preferred_username sAMAccountName
      openid_idp_client_id                 = "123456789"     # replace with valid <client-id>
      openid_idp_client_secret             = "123456789" # replace with valid <client-secret>
      openid_idp_extra_scopes              = (["email","profile"])
      #openid_idp_extra_authorize_parameters = ""
      openid_idp_issuer                    = "https://example.com"
    }
  }

}

  #  openid-idp = {
  #    name                                 = "openid-idp"
  #    idp_type                             = "openid"
  #    openid_idp_client_id                 = "123456789"     # replace with valid <client-id>
  #    openid_idp_client_secret             = "123456789" # replace with valid <client-secret>
  #    openid_idp_ca                        = ""
  #    openid_idp_issuer                    = "https://example.com"
  #    openid_idp_claims_groups             = jsonencode(["group"])
  #    openid_idp_claims_email              = jsonencode(["email"])
  #    openid_idp_claims_preferred_username = jsonencode(["preferred_username"])
  #    #openid_idp_claims_preferred_username = "[\"preferred_username\"]"
  #    openid_idp_extra_scopes              = jsonencode(["email","profile"])
  #  }