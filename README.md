export TF_VAR_RHCS_TOKEN="...."

terraform init -backend-config="clusters/<cluster_name>/backend.tfvars

terraform plan -var-file="clusters/<cluster_name>/cluster_variables.json"

terraform apply -var-file="clusters/<cluster_name>/cluster_variables.json"

terraform destroy -var-file="clusters/<cluster_name>/cluster_variables.json"