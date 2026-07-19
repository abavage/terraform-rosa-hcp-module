#resource "shell_script" "gitops_bootstrap" {
#
#  lifecycle_commands {
#    create = "${path.module}/scripts/gitops-bootstrap.sh"
#    #create = "${path.module}/scripts/no-operation-delete.sh"
#    delete = "${path.module}/scripts/no-operation-delete.sh"
#  }
#  environment = {
#    admin_username                      = module.rosa_cluster_hcp.cluster_admin_username
#    api_url                             = module.rosa_cluster_hcp.cluster_api_url
#    admin_passwd                        = random_string.random.result
#    gitopsStartingCsv                   = var.gitops_bootstrap.gitopsStartingCsv
#    infrastructureGitPath               = var.infrastructureGitPath
#    namespaceGitPath                    = var.namespaceGitPath
#    cluster_name                        = var.cluster_name
#    ebsKmsKeyId                         = resource.aws_kms_key.ebs.arn
#    efsFileSystemId                     = data.aws_efs_file_system.fsid.id
#    gitRepoUserName                     = var.gitRepoUserName
#    gitRepoPasswd                       = var.gitRepoPasswd
#    domain                              = module.rosa_cluster_hcp.cluster_domain
#    gitopsOperatorBootstrapChartVersion = var.gitops_bootstrap.gitopsOperatorBootstrapChartVersion
#    appOfAppsVersion                    = var.gitops_bootstrap.appOfAppsVersion
#    gitopsOperatorChartVersion          = var.gitopsOperatorChartVersion
#    namespacesChartVersion              = var.gitops_bootstrap.namespacesChartVersion
#    enable                              = true
#  }
#  sensitive_environment = {}
#
#  #triggers = {
#  #  always_run = timestamp()
#  #}
#
#  depends_on = [
#    module.rosa_cluster_hcp
#  ]
#
#}

resource "terraform_data" "bootstrap_gitops" {
  provisioner "local-exec" {

    environment = {
      admin_username        = module.rosa_cluster_hcp.cluster_admin_username
      api_url               = module.rosa_cluster_hcp.cluster_api_url
      admin_passwd          = random_string.random.result
      gitopsStartingCsv     = var.gitops_bootstrap.gitopsStartingCsv
      infrastructureGitPath = var.infrastructureGitPath
      namespaceGitPath      = var.namespaceGitPath
      cluster_name          = var.cluster_name
      ebsKmsKeyId           = resource.aws_kms_key.ebs.arn
      efsFileSystemId       = data.aws_efs_file_system.fsid.id
      #gitRepoUserName                     = var.gitRepoUserName
      #gitRepoPasswd                       = var.gitRepoPasswd
      domain                              = module.rosa_cluster_hcp.cluster_domain
      gitopsOperatorBootstrapChartVersion = var.gitops_bootstrap.gitopsOperatorBootstrapChartVersion
      appOfAppsVersion                    = var.gitops_bootstrap.appOfAppsVersion
      gitopsOperatorChartVersion          = var.gitopsOperatorChartVersion
      namespacesChartVersion              = var.gitops_bootstrap.namespacesChartVersion
      enable                              = true
    }

    command = <<-EOT
      sh "${path.module}/scripts/gitops-bootstrap.sh"
    EOT
  }

  depends_on = [
    module.rosa_cluster_hcp
  ]
  triggers_replace = {
    always_run = timestamp()
  }

}