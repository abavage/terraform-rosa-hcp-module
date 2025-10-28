resource "shell_script" "gitops_bootstrap" {

  lifecycle_commands {
    create = "${path.module}/scripts/gitops-bootstrap.sh"
    delete = "${path.module}/scripts/no-operation-delete.sh"

    #create = templatefile(
    # "./scripts/gitops-bootstrap.tftpl",
    # {
    #   admin_username     = module.rosa_cluster_hcp.cluster_admin_username
    #   api_url            = module.rosa_cluster_hcp.cluster_api_url
    #   admin_passwd       = random_string.random.result
    #   gitops_startingcsv = var.gitops_bootstrap.gitops_startingcsv
    #   infrastructureGitPath     = var.infrastructureGitPath
    #   namespaceGitPath   = var.namespaceGitPath
    #   cluster_name       = var.cluster_name
    #   ebsKmsKeyId        = resource.aws_kms_key.ebs.arn
    #   efsFileSystemId    = data.aws_efs_file_system.fsid.id
    #   enable             = true
    #)
    #delete = templatefile(
    # "./scripts/gitops-bootstrap.tftpl",
    # {
    #   admin_username     = module.rosa_cluster_hcp.cluster_admin_username
    #   api_url            = module.rosa_cluster_hcp.cluster_api_url
    #   admin_passwd       = random_string.random.result
    #   gitops_startingcsv = var.gitops_bootstrap.gitops_startingcsv
    #   infrastructureGitPath     = var.infrastructureGitPath
    #   cluster_name       = var.cluster_name
    #   namespaceGitPath   = var.namespaceGitPath
    #   ebsKmsKeyId        = resource.aws_kms_key.ebs.arn
    #   efsFileSystemId    = data.aws_efs_file_system.fsid.id
    #   enable             = false

    #)
  }
  environment           = {
    admin_username     = module.rosa_cluster_hcp.cluster_admin_username
    api_url            = module.rosa_cluster_hcp.cluster_api_url
    admin_passwd       = random_string.random.result
    gitops_startingcsv = var.gitops_bootstrap.gitops_startingcsv
    infrastructureGitPath     = var.infrastructureGitPath
    namespaceGitPath   = var.namespaceGitPath
    cluster_name       = var.cluster_name
    ebsKmsKeyId        = resource.aws_kms_key.ebs.arn
    efsFileSystemId    = data.aws_efs_file_system.fsid.id
    enable             = true
  }
  sensitive_environment = {}

  triggers = {
    always_run = timestamp()
  }

  depends_on = [
    module.rosa_cluster_hcp
  ]

}
