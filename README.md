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