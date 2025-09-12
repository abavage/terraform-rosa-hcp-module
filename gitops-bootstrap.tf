resource "shell_script" "gitops_bootstrap" {

  lifecycle_commands {
    create = templatefile(
      "./scripts/gitops-bootstrap.tftpl",
      {
        admin_username     = module.rosa_cluster_hcp.cluster_admin_username
        api_url            = module.rosa_cluster_hcp.cluster_api_url
        admin_passwd       = random_string.random.result
        gitops_startingcsv = var.gitops_bootstrap.gitops_startingcsv
        clusterGitPath     = var.clusterGitPath
        ebsKmsKeyId        = resource.aws_kms_key.ebs.arn
        efsFileSystemId    = data.aws_efs_file_system.fsid.id
        enable             = true
    })
    delete = templatefile(
      "./scripts/doit.tftpl",
      {
        admin_username     = module.rosa_cluster_hcp.cluster_admin_username
        api_url            = module.rosa_cluster_hcp.cluster_api_url
        admin_passwd       = random_string.random.result
        gitops_startingcsv = var.gitops_bootstrap.gitops_startingcsv
        clusterGitPath     = var.clusterGitPath
        ebsKmsKeyId        = resource.aws_kms_key.ebs.arn
        efsFileSystemId    = data.aws_efs_file_system.fsid.id
        enable             = false

    })
  }
  environment           = {}
  sensitive_environment = {}

  triggers = {
    always_run = timestamp()
  }

  depends_on = [
    module.rosa_cluster_hcp
  ]

}