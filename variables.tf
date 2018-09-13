variable "aws_region" {
  default     = "eu-west-1"
  description = "AWS Region fuer das Deployment"
}
variable "tag_responsibel" {
  description = "Wer ist fuer die Resourcen zustaendig"
}
variable "aws_key_name" {}
variable "project_name" {}
variable "optimal_design" {
  default = false
}
variable "laufzeit_tage" {
  default = 60
}

variable "debug_on" {
  default = true
}

variable "remote_state_bucket" {
  default = ""
}

variable "remote_state_key" {
  default = "baseinfrastruktur.state"
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

variable "DmzDockerCluster_deploy" {
  default = false
}
