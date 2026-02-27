cluster_name        = "one"
#openshift_version   = "4.19.6"
openshift_version   = "4.17.43" # cenitex
#openshift_version    = "4.18.30"

#upgrade_acknowledgements_for = "4.18"

aws_region          = "ap-southeast-2"

private_aws_subnet_ids = [
  "subnet-0aeee693feb103fe4",
  "subnet-0491b4678857ddcc4",
  "subnet-06508eb002acb5b08",
]

public_aws_subnet_ids = [
  "subnet-063a935dac84372b5"
]

aws_private_subnet_cidrs = [
  "10.0.8.0/23",
  "10.0.10.0/23",
  "10.0.12.0/23",
]

aws_availability_zones = [
  "ap-southeast-2a",
  "ap-southeast-2b",
  "ap-southeast-2c",
]

private = false

properties = {
  zero_egress = "false"
}

infrastructureGitPath = "nonprod/one/infrastructure.yaml"
namespaceGitPath      = "nonprod/one"

gitops_bootstrap = {
  gitops_startingcsv = "openshift-gitops-operator.v1.19.0"
}

etcd_encryption = true

replicas             = 3
compute_machine_type = "m5.xlarge"

default_workers_min_replicas = 1
default_workers_max_replicas = 1

default_workers_labels = {
  "k8s.ovn.org/egress-assignable" = ""
  clustername                    = "one"
}

machine_cidr = "10.0.0.0/16"
service_cidr = "172.30.0.0/16"
pod_cidr     = "10.128.0.0/14"
host_prefix  = 23

autoscaler_max_nodes_total = 3

#machine_pools = {
#  "pool-01" = {
#    name = "pool-01"
#
#    aws_node_pool = {
#      instance_type                 = "m5.xlarge"
#      tags                          = {}
#      additional_security_group_ids = null
#    }
#
#    auto_repair = true
#
#    labels = {
#      "k8s.ovn.org/egress-assignable" = ""
#      clustername                    = "one"
#    }
#
#    autoscaling = {
#      enabled      = true
#      min_replicas = 1
#      max_replicas = 1
#    }
#
#    openshift_version      = "4.19.6"
#    #openshift_version   = "4.17.15" cenitex
#    subnet_id              = "subnet-04d2633265eee24e2"
#    ignore_deletion_error  = true
#    kubelet_configs        = "custom-kubelet"
#  }
#}
