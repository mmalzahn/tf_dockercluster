locals {
  common_tags {
    responsible     = "${var.tag_responsibel}"
    tf_managed      = "1"
    tf_project      = "dca:${terraform.workspace}:${replace(var.project_name," ","")}"
    tf_project_name = "DCA_${replace(var.project_name," ","_")}_${terraform.workspace}"
    tf_environment  = "${terraform.workspace}"
    tf_created      = "${timestamp()}"
    tf_runtime      = "${var.laufzeit_tage}"
    tf_responsible  = "${var.tag_responsibel}"
    tf_configId     = "${local.projectId}"
  }

  projectId       = "${lower(random_string.projectId.result)}"
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

resource "random_integer" "randomSshPortIntern" {
  min = 13000
  max = 14000
}

resource "random_integer" "randomDockerPortIntern" {
  min = 15001
  max = 16000
}

resource "random_integer" "randomSshPortExtern" {
  min = 12000
  max = 13000
}

resource "random_integer" "randomDockerPortExtern" {
  min = 14001
  max = 15000
}

data "template_file" "connectDockerSocketIntern" {
  template = "${file("tpl/connectDocker.tpl")}"

  vars {
    random_port      = "${random_integer.randomDockerPortIntern.result}"
    userid           = "${lower(random_string.projectId.result)}"
    host_fqdn        = "${aws_route53_record.dockerhost_masterintern.fqdn}"
    bastionhost_fqdn = "${element(data.terraform_remote_state.baseInfra.bastion_dns,0)}"
    workspace        = "${terraform.workspace}"
  }
}

data "template_file" "connectDockerSocketExtern" {
  template = "${file("tpl/connectDocker.tpl")}"

  vars {
    random_port      = "${random_integer.randomDockerPortExtern.result}"
    userid           = "${lower(random_string.projectId.result)}"
    host_fqdn        = "${aws_route53_record.dockerhost_masterextern.fqdn}"
    bastionhost_fqdn = "${element(data.terraform_remote_state.baseInfra.bastion_dns,0)}"
    workspace        = "${terraform.workspace}"
  }
}

data "template_file" "startSshDockerInternScript" {
  template = "${file("tpl/start_ssh.tpl")}"

  vars {
    random_port      = "${random_integer.randomSshPortIntern.result}"
    userid           = "${lower(random_string.projectId.result)}"
    host_fqdn        = "${aws_route53_record.dockerhost_masterintern.fqdn}"
    bastionhost_fqdn = "${element(data.terraform_remote_state.baseInfra.bastion_dns,0)}"
    workspace        = "${terraform.workspace}"
  }
}

data "template_file" "startSshDockerExternScript" {
  template = "${file("tpl/start_ssh.tpl")}"

  vars {
    random_port      = "${random_integer.randomSshPortExtern.result}"
    userid           = "${lower(random_string.projectId.result)}"
    host_fqdn        = "${aws_route53_record.dockerhost_masterextern.fqdn}"
    bastionhost_fqdn = "${element(data.terraform_remote_state.baseInfra.bastion_dns,0)}"
    workspace        = "${terraform.workspace}"
  }
}
data "template_file" "installscript_master_intern" {
  template = "${file("tpl/installdockermaster.tpl")}"

  vars {
    file_system_id = "${element(data.terraform_remote_state.baseInfra.efs_filesystem_id,0)}"
    efs_directory  = "/efs"
    project_id     = "${local.projectId}-intern"
    user_id        = "${lower(random_string.projectId.result)}"
    public_key     = "${trimspace(tls_private_key.private_key_dockercluster.public_key_openssh)}"
  }
}
data "template_file" "installscript_master_extern" {
  template = "${file("tpl/installdockermaster.tpl")}"

  vars {
    file_system_id = "${element(data.terraform_remote_state.baseInfra.efs_filesystem_id,0)}"
    efs_directory  = "/efs"
    project_id     = "${local.projectId}-extern"
    user_id        = "${lower(random_string.projectId.result)}"
    public_key     = "${trimspace(tls_private_key.private_key_dockercluster.public_key_openssh)}"
  }
}