export RHCS_TOKEN="token..."

terraform plan -var-file="cluster_variables.json"

terraform apply -var-file="cluster_variables.json"

terraform destroy -var-file="cluster_variables.json"