data "template_file" "installscript_master_intern" {
  template = "${file("tpl/installdockermaster.tpl")}"

  vars {
    file_system_id = "${element(data.terraform_remote_state.baseInfra.efs_filesystem_id,0)}"
    efs_directory  = "/efs"
    project_id     = "${local.projectId}"
    user_id        = "${lower(random_string.projectId.result)}"
    public_key     = "${trimspace(tls_private_key.private_key_dockercluster.public_key_openssh)}"
  }
}

resource "aws_instance" "internerDockerhostMaster" {
  ami           = "${data.aws_ami.dockerhostPackerAmi.id}"
  instance_type = "${var.dockercluster_instance_type}"
  subnet_id     = "${element(data.terraform_remote_state.baseInfra.subnet_ids_backend,0)}"

  vpc_security_group_ids = [
    "${lookup(data.terraform_remote_state.baseInfra.secgroups,"ssh_bastion_in")}",
    "${aws_security_group.SG_DockerSocket_IN_from_Bastionhost.id}",
    "${aws_security_group.SG_DockerSwarmCom_from_backendtiersubnets.id}",
  ]

  depends_on = [
    "aws_security_group.SG_DockerSocket_IN_from_Bastionhost",
    "aws_security_group.SG_DockerSwarmCom_from_backendtiersubnets",
  ]

  associate_public_ip_address = "false"
  key_name                    = "${local.resource_prefix}key"
  user_data                   = "${data.template_file.installscript_master_intern.rendered}"

  lifecycle {
    ignore_changes        = ["tags.tf_created"]
    create_before_destroy = "true"
  }

  tags = "${merge(local.common_tags,
            map(
              "Name", "${local.resource_prefix}DockerClusterMasterIntern"
              )
              )}"
}

resource "aws_route53_record" "dockerhost_masterintern" {
  allow_overwrite = "true"
  depends_on      = ["aws_instance.internerDockerhostMaster"]
  name            = "docker0.intern.${terraform.workspace}"
  ttl             = "60"
  type            = "A"
  records         = ["${aws_instance.internerDockerhostMaster.private_ip}"]
  zone_id         = "${data.aws_route53_zone.dca_poc_domain.zone_id}"
}

data "template_file" "startSshScript" {
  template = "${file("tpl/start_ssh.tpl")}"

  vars {
    random_port      = "${random_integer.randomScriptPort.result}"
    userid           = "${lower(random_string.projectId.result)}"
    host_fqdn        = "${aws_route53_record.dockerhost_masterintern.fqdn}"
    bastionhost_fqdn = "${element(data.terraform_remote_state.baseInfra.bastion_dns,0)}"
    workspace        = "${terraform.workspace}"
  }
}
