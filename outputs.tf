output "zlogin_details" {
  value = {
    api_url =  module.rosa_cluster_hcp.cluster_api_url
    admin_username = var.admin_credentials_username
    admin_passwd = nonsensitive(random_string.random.result)
  }
}