#resource "shell_script" "enable_autoscaling_workers" {

#  lifecycle_commands {
#    create = templatefile(
#      "./scripts/enable-autoscaling-workers.tftpl",
#      {
#        cluster                         = var.cluster_name
#        enable                          = true
#        token                           = var.RHCS_TOKEN
#        default_workers_min_replcias    = var.default_workers_min_replcias
#        default_workers_max_replcias    = var.default_workers_max_replcias
#        default_workers_labels_csv     = local.default_workers_labels_csv
#    })
#    delete = templatefile(
#      "./scripts/enable-autoscaling-workers.tftpl",
#      {
#        cluster                         = var.cluster_name
#        enable                          = true
#        token                           = var.RHCS_TOKEN
#        default_workers_min_replcias    = var.default_workers_min_replcias
#        default_workers_max_replcias    = var.default_workers_max_replcias
#        default_workers_labels_csv     = local.default_workers_labels_csv
#    })
#  }
#  environment           = {}
#  sensitive_environment = {}
#  depends_on = [
#    module.rosa_cluster_hcp
#  ]
#}



## using null_resource as scott winkler wouldn't pass the labels correctly
resource "null_resource" "enable_autoscaling_workers" {
  #triggers = {
  #  always_run = timestamp()
  #}

  provisioner "local-exec" {
    command = <<EOT
rosa login -t ${var.RHCS_TOKEN} 2>/dev/null &&
rosa edit machinepool -c "${var.cluster_name}" --enable-autoscaling --min-replicas "${var.default_workers_min_replicas}" --max-replicas "${var.default_workers_max_replicas}" --labels '${local.default_workers_labels_csv}' workers-0 2>/dev/null &&
rosa edit machinepool -c "${var.cluster_name}" --enable-autoscaling --min-replicas "${var.default_workers_min_replicas}" --max-replicas "${var.default_workers_max_replicas}" --labels '${local.default_workers_labels_csv}' workers-1 2>/dev/null &&
rosa edit machinepool -c "${var.cluster_name}" --enable-autoscaling --min-replicas "${var.default_workers_min_replicas}" --max-replicas "${var.default_workers_max_replicas}" --labels '${local.default_workers_labels_csv}' workers-2 2>/dev/null

EOT
  }
  
  depends_on = [
    module.rosa_cluster_hcp
  ]
}