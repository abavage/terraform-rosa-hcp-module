terraform {
  backend "s3" {
    bucket         = "this-cluster-rosa-terraform-statefile"
    key            = "this-cluster/terraform.tfstate"
    region         = "ap-southeast-2"
    dynamodb_table = "this-cluster-rosa-terraform-statefile"
    encrypt        = true
  }
}