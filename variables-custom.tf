variable "RHCS_TOKEN" {
  type        = string
  nullable    = false
  description = "API key for the cluster to access api.openshift.com"
}
variable "private_aws_subnet_ids" {
  type        = list(string)
  nullable    = false
  description = "list of the private subnets" 
}

variable "public_aws_subnet_ids" {
  type        = list(string)
  nullable    = false
  description = "list of the public subnets" 
}

variable "aws_private_subnet_cidrs" {
  type        = list(string)
  nullable    = false
  description = "private subnet cidr range"
}

variable "default_workers_min_replicas" {
  type        = number
  default     = null
  description = "minimum replcias for the default workers machinepools"
}

variable "default_workers_max_replicas" {
  type        = number
  default     = null
  description = "max replcias for the default workers machinepools"
}

variable "default_workers_labels" {
  type        = map(string)
  default     = null
  description = "Additional node lables to add to the workers machinepools"
}