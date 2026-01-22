cluster_name        = "one"
openshift_version   = "4.19.6"
#openshift_version   = "4.17.15" cenitex
#openshift_version    = "4.18.30"

#upgrade_acknowledgements_for = "4.18"

aws_region          = "ap-southeast-2"

private_aws_subnet_ids = [
  "subnet-04d2633265eee24e2",
  "subnet-043a6035f0e9373e5",
  "subnet-0ffcbe1f2a454ca54",
]

public_aws_subnet_ids = [
  #"subnet-0e8b43c72ece8461e"
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

private = true

properties = {
  zero_egress = "true"
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
default_workers_max_replicas = 2

default_workers_labels = {
  "k8s.ovn.org/egress-assignable" = ""
  clustername                    = "one"
}

machine_cidr = "10.0.0.0/16"
service_cidr = "172.30.0.0/16"
pod_cidr     = "10.128.0.0/14"
host_prefix  = 23

autoscaler_max_nodes_total = 8

machine_pools = {
  "pool-01" = {
    name = "pool-01"

    aws_node_pool = {
      instance_type                 = "m5.xlarge"
      tags                          = {}
      additional_security_group_ids = null
    }

    auto_repair = true

    labels = {
      "k8s.ovn.org/egress-assignable" = ""
      clustername                    = "one"
    }

    autoscaling = {
      enabled      = true
      min_replicas = 1
      max_replicas = 1
    }

    openshift_version      = "4.19.6"
    #openshift_version   = "4.17.15" cenitex
    subnet_id              = "subnet-04d2633265eee24e2"
    ignore_deletion_error  = true
    kubelet_configs        = "custom-kubelet"
  }
}