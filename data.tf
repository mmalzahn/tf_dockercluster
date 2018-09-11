locals {
  common_tags {
    responsible     = "${var.tag_responsibel}"
    tf_managed      = "1"
    tf_project      = "dca:${terraform.workspace}:${random_id.randomPart.b64_url}:${replace(var.project_name," ","")}"
    tf_project_name = "DCA_${replace(var.project_name," ","_")}_${terraform.workspace}"
    tf_environment  = "${terraform.workspace}"
    tf_created      = "${timestamp()}"
    tf_runtime      = "${var.laufzeit_tage}"
    tf_responsible  = "${var.tag_responsibel}"
    tf_configId     = "${local.projectId}"
  }
  projectId ="${lower(random_string.projectId.result)}"
  resource_prefix = "tf-${random_string.projectId.result}-${terraform.workspace}-"
}
data "terraform_remote_state" "baseInfra" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket}"
    key    = "env:/${terraform.workspace}/${var.remote_state_key}"
    region = "${var.remote_state_bucket_region}"
  }
}

data "aws_route53_zone" "dca_poc_domain" {
  name = "${data.terraform_remote_state.baseInfra.dns_name}"
}

data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

 data "aws_ami" "dockerhostPackerAmi" {
  filter {
    name   = "tag:tf_packerid"
    values = ["docker001"]
  }

  owners      = ["681337066511"]
  most_recent = true
}

resource "random_string" "projectId" {
  length  = 10
  special = false
  upper   = false
  number  = false
}
resource "random_integer" "randomScriptPort" {
  min   = 12000
  max   = 14000
}
