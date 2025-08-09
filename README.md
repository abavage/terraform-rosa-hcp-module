export TF_VAR_RHCS_TOKEN="...."

terraform plan -var-file="cluster_variables.json"

terraform apply -var-file="cluster_variables.json"

terraform destroy -var-file="cluster_variables.json"