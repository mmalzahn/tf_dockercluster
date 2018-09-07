variable "aws_region" {
  default     = "eu-west-1"
  description = "AWS Region fuer das Deployment"
}
variable "aws_accountId" {}
variable "tag_responsibel" {
  description = "Wer ist fuer die Resourcen zustaendig"
}
variable "aws_key_name" {}
variable "project_name" {}
variable "optimal_design" {
  default = false
}
variable "ssh_pubkey_prefix" {
  default = "keys/"
}
variable "laufzeit_tage" {
  default = 60
}

variable "debug_on" {
  default = true
}

variable "aws_amis" {
  default = {
    eu-west-1 = "ami-e4515e0e"
    eu-west-2 = "ami-b2b55cd5"
    us-east-2 = "ami-40142d25"
  }
}

variable "remote_state_bucket" {
  default = ""
}

variable "remote_state_key" {
  default = ""
}

variable "remote_state_bucket_region" {
  default = ""
}

variable "dockercluster_instance_type" {
  default = "t2.micro"
}

variable "dockercluster_deploy" {
  default = false
}

