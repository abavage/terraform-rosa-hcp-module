### ROSA HCP Terraform 

## 

## 
export TF_VAR_RHCS_TOKEN="...."

export RHCS_TOKEN="...."

Optional if using a statebucket and not the local filesystem.  
terraform init -backend-config="clusters/<cluster_name>/backend.tfvars"

terraform plan -var-file="clusters/<cluster_name>/cluster_variables.json"

terraform apply -var-file="clusters/<cluster_name>/cluster_variables.json"

terraform destroy -var-file="clusters/<cluster_name>/cluster_variables.json"


Undocumented for SSO login https://console.redhat.com/openshift/token
RHCS_CLIENT_ID and RHCS_CLIENT_SECRET.  

### ROSA HCP Terraform 
Terraform module which creates ROSA HCP cluster

## Introduction
This module serves as a comprehensive solution for deploying, configuring and managing Red Hat OpenShift on AWS (ROSA) Hosted Control Plane (HCP) clusters within your AWS environment. With a focus on simplicity and efficiency, this module streamlines the process of setting up and maintaining ROSA HCP clusters, enabling users to use the power of OpenShift on AWS infrastructure effortlessly.


## Sub-Modules
Sub-modules included in this module:

* account-iam-resource: Handles the provisioning of Identity and Access Management (IAM) resources required for managing access and permissions in the AWS account associated with the ROSA HCP cluster.

* idp: Responsible for configuring Identity Providers (IDPs) within the ROSA HCP cluster, faciliting seamless integration with external authentication system such as Github (GH), GitLab, Google, HTPasswd, LDAP and OpenID Connect (OIDC).

* machine-pool: Facilitates the management of machine pools within the ROSA HCP cluster, enabling users to scale resources and adjust specifications based on workload demands.

* oidc-config-and-provider: Manages the configuration of OpenID Connect (OIDC) hosted files and providers for ROSA HCP clusters, enabling secure authentication and access control mechanisms for operator roles.

* operator-roles: Oversees the management of roles assigned to operators within the ROSA HCP cluster, enabling to perform required actions with appropriate permissions on the lifecyle of a cluster.

* rosa-cluster-hcp: Handles the core configuration and provisioning of the ROSA HCP cluster, including cluster networking, security settings and other essential components.

The primary sub-modules responsible for ROSA HCP cluster creation includes optional configurations for setting up account roles, operator roles and OIDC config/provider. This comprehensive module handles the entire process of provisioning and configuring ROSA HCP clusters in your AWS environment.

## Pre-requisites
* [Terrform cli ](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) ( > 1.4.6)

* An AWS account and the associated credentials that allow you to create resources. These credentials must be configured for the AWS provider (see Authentication and Configuration section in AWS terraform provider documentation.)

* The [ROSA getting started AWS prerequisites](https://console.redhat.com/openshift/create/rosa/getstarted)  must be completed.

* A valid [OpenShift Cluster Manager API Token](https://console.redhat.com/openshift/token) must be configured. See [Authentication and configuration for more information](https://registry.terraform.io/providers/terraform-redhat/rhcs/latest/docs#authentication-and-configuration)

### Additonal Supporting Tools
* [helm](https://console.redhat.com/openshift/downloads)
* [oc](https://console.redhat.com/openshift/downloads)
* [rosa](https://console.redhat.com/openshift/downloads)

## Providers

| Name | Version |
|------|---------|
| aws  | >= 5.38.0 |
| rhcs | >= 1.7.0 |
| scottwinkler/shell | >= 1.7.10 |
| hashicorp/time | >= 0.9 |
| hashicorp/null | >= 3.0.0 |
| hashicorp/random | >= 3.0.0 |

## Modules
| Name | Source | Version |
|------|--------|---------|
|account_iam_resources | [github](https://github.com/terraform-redhat/terraform-rhcs-rosa-hcp/tree/main/modules/account-iam-resources) | NA |
| oidc_config_and_provider | [github](https://github.com/terraform-redhat/terraform-rhcs-rosa-hcp/tree/main/modules/oidc-config-and-provider)| NA |
| operator_roles | [github](https://github.com/terraform-redhat/terraform-rhcs-rosa-hcp/tree/main/modules/operator-roles)| NA |
| rosa_cluster_hcp | [github](https://github.com/terraform-redhat/terraform-rhcs-rosa-hcp/tree/main/modules/rosa-cluster-hcp) | NA |
| rhcs_hcp_machine_pool | [github](https://github.com/terraform-redhat/terraform-rhcs-rosa-hcp/tree/main/modules/machine-pool)| NA |
| rhcs_identity_provider | [github](https://github.com/terraform-redhat/terraform-rhcs-rosa-hcp/tree/main/modules/idp)| NA |
| rhcs_hcp_kubelet_configs | [github](https://github.com/terraform-redhat/terraform-rhcs-rosa-hcp/tree/main/modules/kubelet-configs) | NA |


## Variables




## Custom Variables
| Name | Description | Type | Default | Required | Example |
|------|-------------|------|---------|----------|---------|
| RHCS_TOKEN | API key for the cluster to access api.openshift.com | string | NA | true | |
| private_aws_subnet_ids | List of the private subnets | list(string) | NA | yes | |
| aws_private_subnet_cidrs | Private subnet cidr range | list(string) | NA | yes | |
| default_workers_min_replicas | Minimum replcias for the default workers machinepools | number | NA | yes | |
| default_workers_max_replicas | Max replcias for the default workers machinepools | number | NA  | yes | |
| default_workers_labels | Additional node lables to add to the workers machinepools | map(string) | NA | no | |
| gitops_bootstrap | Variables passed into the gitops-operator-bootstrap helm chart | map(string) | NA | yes | gitops_startingcsv  = "openshift-gitops-operator.v1.18.0" |
| infrastructureGitPath | The git repo path to where the cluster will source it helm variables for infrastructure components | string | NA | yes | |
| namespaceGitPath | The git repo path to where the cluster will source it helm variables for namespaces creation | string | NA | yes | |
| gitRepoUserName | Username to access the authenticated github repo for argocd repositories | string | NA | no | | |
| gitRepoPasswd | Password  to access the authenticated github repo for argocd repositories | string | NA | no | |













