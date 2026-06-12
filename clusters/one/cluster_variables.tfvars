cluster_name        = "one"
#openshift_version   = "4.19.6"
#openshift_version   = "4.17.43" # cenitex
#
#openshift_version     = "4.18.36" # cenitex
#openshift_version    = "4.18.40"
#openshift_version    = "4.19.31"
#openshift_version    = "4.20.22"
openshift_version     = "4.21.10"

#upgrade_acknowledgements_for = "4.18"
#upgrade_acknowledgements_for = "4.19"
upgrade_acknowledgements_for = "4.20"

aws_region          = "ap-southeast-2"

private_aws_subnet_ids = [
  "subnet-0f20cdd1413aa8bca",
  "subnet-0fb2cd631df0027e2",
  "subnet-0449232b208c260b8"
]



public_aws_subnet_ids = [
  "subnet-042fd086f8a94beb7"
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

sns_endpoint_subscription = [
  "abavage@redhat.com",
  "abavage@gmail.com"
]


gitopsOperatorChartVersion = "0.0.4"

gitops_bootstrap = {
  gitopsStartingCsv = "openshift-gitops-operator.v1.20.1"
  gitopsOperatorBootstrapChartVersion = "0.0.23"
  appOfAppsVersion = "0.0.3"
  namespacesChartVersion = "0.0.4"
}

etcd_encryption = true

replicas             = 3
compute_machine_type = "m5.xlarge"

default_workers_min_replicas = 1
default_workers_max_replicas = 2

default_workers_labels = {
  "k8s.ovn.org/egress-assignable" = ""
  clustername                    = "one"
}

machine_cidr = "10.0.0.0/16"
service_cidr = "172.30.0.0/16"
pod_cidr     = "10.128.0.0/14"
host_prefix  = 23

autoscaler_max_nodes_total = 10

machine_pools = {
  "pool-01" = {
    name = "pool-01"

    aws_node_pool = {
      instance_type                 = "m5.xlarge"
      tags                          = {}
      additional_security_group_ids = null
      node_drain_grace_period       = 10 
    }

    auto_repair = true

    labels = {
      "k8s.ovn.org/egress-assignable" = ""
      clustername                    = "one"
    }

    autoscaling = {
      enabled      = true
      min_replicas = 0
      max_replicas = 2
    }

    openshift_version      = "4.21.10"
    #openshift_version   = "4.17.15" cenitex
    subnet_id              = "subnet-0449232b208c260b8"
    ignore_deletion_error  = true
    kubelet_configs        = "custom-kubelet"
  }
}
