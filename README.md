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


| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| account_role_prefix | User-defined prefix for all generated AWS resources (default "account-role-<random>") | `string` | `null` | no |
| additional_trust_bundle| A string containing a PEM-encoded X.509 certificate bundle that will be added to the nodes' trusted certificate store. | `string` | `null` | no |
| admin_credentials_password | Admin password that is created with the cluster. The password must contain at least 14 characters (ASCII-standard) without whitespaces including uppercase letters, lowercase letters, and numbers or symbols. | `string` | `null` | no |
| admin_credentials_username| Admin username that is created with the cluster. auto generated username - "cluster-admin" | `string` | `null` | no |
| autoscaler_max_node_provision_time | Maximum time cluster-autoscaler waits for node to be provisioned. | `string` | `null` | no |
| autoscaler_max_nodes_total | Maximum number of nodes in all node groups. Cluster autoscaler will not grow the cluster beyond this number. | `number` | `null` | no |
| autoscaler_max_pod_grace_period | Gives pods graceful termination time before scaling down. | `number` | `null` | no |
| autoscaler_pod_priority_threshold | To allow users to schedule 'best-effort' pods, which shouldn't trigger Cluster Autoscaler actions, but only run when there are spare resources available. | `number` | `null` | no |
| aws_additional_allowed_principals | The additional allowed principals to use when installing the cluster. | `list(string)` | `null` | no |
| aws_additional_compute_security_group_ids| The additional security group IDs to be added to the default worker machine pool. | `list(string)` | `null` | no |
| aws_availability_zones | The AWS availability zones where instances of the default worker machine pool are deployed. Leave empty for the installer to pick availability zones | `list(string)` | `[]` | no |
| aws_billing_account_id | The AWS billing account identifier where all resources are billed. If no information is provided, the data will be retrieved from the currently connected account. | `string` | `null` | yes |
| aws_subnet_ids| The Subnet IDs to use when installing the cluster. | `list(string)` | n/a | yes |
| base_dns_domain | Base DNS domain name previously reserved, e.g. '1vo8.p3.openshiftapps.com'. | `string` | `null` | no |
| cluster_autoscaler_enabled | Enable Autoscaler for this cluster. This resource is currently unavailable and using will result in error 'Autoscaler configuration is not available' | `bool` | `false` | no |
| cluster_name | Name of the cluster. After the creation of the resource, it is not possible to update the attribute value. | `string` | n/a | yes |
| compute_machine_type | Identifies the Instance type used by the default worker machine pool e.g. `m5.xlarge`. Use the `rhcs_machine_types` data source to find the possible values. | `string` | `null` | no |
| create_account_roles | Create the aws account roles for rosa | `bool` | `false` | no |
| create_admin_user | To create cluster admin user with default username `cluster-admin` and generated password. It will be ignored if `admin_credentials_username` or `admin_credentials_password` is set. (default: false) | `bool` | `null` | no |
| create_dns_domain_reservation | Creates reserves a dns domain domain for the cluster. This value will be created by the install step if not pre created via this configuration. | `bool` | `false` | no |
| create_oidc | Create the oidc resources. This value should not be updated, please create a new resource instead or utilize the submodule to create a new oidc config | `bool` | `false` | no |
| create_operator_roles | Create the aws account roles for rosa | `bool` | `false` | no |
| default_ingress_listening_method | Listening Method for ingress. Options are ["internal", "external"]. Default is "external". When empty is set based on private variable. | `string` | `""` | no |
| input_destroy_timeout | Maximum duration in minutes to allow for destroying resources. (Default: 60 minutes) | `number` | `null` | no |
| input_disable_waiting_in_destroy | Disable addressing cluster state in the destroy resource. Default value is false, and so a `destroy` will wait for the cluster to be deleted. | `bool` | `null` | no |
| domain_prefix | Creates a domain prefix for your ROSA cluster. Defaults to a random string if not set | `string` | `null` | no |
| ec2_metadata_http_tokens | Should cluster nodes use both v1 and v2 endpoints or just v2 endpoint of EC2 Instance Metadata Service (IMDS). Available since OpenShift 4.11.0. | `string` | `"optional"` | no |
| etcd_encryption | Add etcd encryption. By default etcd data is encrypted at rest. This option configures etcd encryption on top of existing storage encryption. | `bool` | `null` | no |
| etcd_kms_key_arn | The key ARN is the Amazon Resource Name (ARN) of a CMK. It is a unique, fully qualified identifier for the CMK. A key ARN includes the AWS account, Region, and the key ID. | `string` | `null` | no |
| host_prefix | Subnet prefix length to assign to each individual node. For example, if host prefix is set to "23", then each node is assigned a /23 subnet out of the given CIDR. | `number` | `null` | no |
| http_proxy | A proxy URL to use for creating HTTP connections outside the cluster. The URL scheme must be http. | `string` | `null` | no |
| https_proxy | A proxy URL to use for creating HTTPS connections outside the cluster. | `string` | `null` | no |
| identity_providers | Provides a generic approach to add multiple identity providers after the creation of the cluster. This variable allows users to specify configurations for multiple identity providers in a flexible and customizable manner, facilitating the management of resources post-cluster deployment. For additional details regarding the variables utilized, refer to the [idp sub-module](./modules/idp). For non-primitive variables (such as maps, lists, and objects), supply the JSON-encoded string. | `map(any)` | `{}` | no |
| ignore_machine_pools_deletion_error | Ignore machine pool deletion error. Assists when cluster resource is managed within the same file for the destroy use case | `bool` | `false` | no |
| kms_key_arn | The key ARN is the Amazon Resource Name (ARN) of a CMK. It is a unique, fully qualified identifier for the CMK. A key ARN includes the AWS account, Region, and the key ID. | `string` | `null` | no |
| input_kubelet_configs | Provides a generic approach to add multiple kubelet configs after the creation of the cluster. This variable allows users to specify configurations for multiple kubelet configs in a flexible and customizable manner, facilitating the management of resources post-cluster deployment. For additional details regarding the variables utilized, refer to the [idp sub-module](./modules/kubelet-configs). For non-primitive variables (such as maps, lists, and objects), supply the JSON-encoded string. | `map(any)` | `{}` | no |
| machine_cidr | Block of IP addresses used by OpenShift while installing the cluster, for example "10.0.0.0/16". | `string` | `null` | no |
| input_machine_pools | Provides a generic approach to add multiple machine pools after the creation of the cluster. This variable allows users to specify configurations for multiple machine pools in a flexible and customizable manner, facilitating the management of resources post-cluster deployment. For additional details regarding the variables utilized, refer to the [machine-pool sub-module](./modules/machine-pool). For non-primitive variables (such as maps, lists, and objects), supply the JSON-encoded string. | `map(any)` | `{}` | no |
| managed_oidc | OIDC type managed or unmanaged oidc. Only active when create\_oidc also enabled. This value should not be updated, please create a new resource instead | `bool` | `true` | no |
| no_proxy | A comma-separated list of destination domain names, domains, IP addresses or other network CIDRs to exclude proxying. | `string` | `null` | no |
| oidc_config_id | The unique identifier associated with users authenticated through OpenID Connect (OIDC) within the ROSA cluster. If create\_oidc is false this attribute is required. | `string` | `null` | no |
| oidc_endpoint_url | Registered OIDC configuration issuer URL, added as the trusted relationship to the operator roles. Valid only when create\_oidc is false. | `string` | `null` | no |
| openshift_version | Desired version of OpenShift for the cluster, for example '4.1.0'. If version is greater than the currently running version, an upgrade will be scheduled. | `string` | n/a | yes |
| operator_role_prefix | User-defined prefix for generated AWS operator policies. Use "account-role-prefix" in case no value provided. | `string` | `null` | no |
| input_path | The arn path for the account/operator roles as well as their policies. Must begin and end with '/'. | `string` | `"/"` | no |
| input_permissions_boundary| The ARN of the policy that is used to set the permissions boundary for the IAM roles in STS clusters. | `string` | `""` | no |
| pod_cidr | Block of IP addresses from which Pod IP addresses are allocated, for example "10.128.0.0/14". | `string` | `null` | no |
| private | Restrict master API endpoint and application routes to direct, private connectivity. (default: false) | `bool` | `false` | no |
| properties | User defined properties. | `map(string)` | `null` | no |
| replicas | Number of worker nodes to provision. This attribute is applicable solely when autoscaling is disabled. Single zone clusters need at least 2 nodes, multizone clusters need at least 3 nodes. Hosted clusters require that the number of worker nodes be a multiple of the number of private subnets. (default: 2) | `number` | `null` | no |
| service_cidr | Block of IP addresses for services, for example "172.30.0.0/16". | `string` | `null` | no |
| tags | Apply user defined tags to all cluster resources created in AWS. After the creation of the cluster is completed, it is not possible to update this attribute. | `map(string)` | `null` | no |
| upgrade_acknowledgements_for | Indicates acknowledgement of agreements required to upgrade the cluster version between minor versions (e.g. a value of "4.12" indicates acknowledgement of any agreements required to upgrade to OpenShift 4.12.z from 4.11 or before). | `string` | `null` | no |
| version_channel_group | Desired channel group of the version [stable, candidate, fast, nightly]. | `string` | `"stable"` | no |
| wait_for_create_complete" | Wait until the cluster is either in a ready state or in an error state. The waiter has a timeout of 20 minutes. (default: true) | `bool` | `true` | no |
| wait_for_std_compute_nodes_complete | Wait until the initial set of machine pools to be available. The waiter has a timeout of 60 minutes. (default: true) | `bool` | `true` | no |























## Custom Variables
| Name | Description | Type | Default | Required | Example |
|------|-------------|------|---------|----------|---------|
| RHCS_TOKEN | API key for the cluster to access api.openshift.com | `string` | NA | `yes` | |
| private_aws_subnet_ids | List of the private subnets | `list(string)` | NA | `yes` | |
| aws_private_subnet_cidrs | Private subnet cidr range | `list(string)` | NA | `yes` | |
| default_workers_min_replicas | Minimum replcias for the default worker machinepools | `number` | NA | `yes` | |
| default_workers_max_replicas | Max replcias for the default worker machinepools | `number` | NA  | `yes` | |
| default_workers_labels | Additional node lables to add to the worker machinepools | `map(string)` | NA | `no` | |
| gitops_bootstrap | Variables passed into the gitops-operator-bootstrap helm chart | `map(string)` | NA | `yes` | gitops_startingcsv  = `"openshift-gitops-operator.v1.18.0"` |
| infrastructureGitPath | The git repo path to where the cluster will source it helm variables for infrastructure components | `string` | NA | `yes` | |
| namespaceGitPath | The git repo path to where the cluster will source it helm variables for namespaces creation | `string` | NA | `yes` | |
| gitRepoUserName | Username to access the authenticated github repo for argocd repositories | `string` | NA | `no` | | |
| gitRepoPasswd | Password  to access the authenticated github repo for argocd repositories | `string` | NA | `no` | |













