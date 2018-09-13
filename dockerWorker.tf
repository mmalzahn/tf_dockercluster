resource "aws_instance" "internerDockerhostWorker" {
  count                       = "${var.dockercluster_deploy ? length(data.terraform_remote_state.baseInfra.subnet_ids_backend) : 0}"
  ami                         = "${data.aws_ami.dockerhostPackerAmi.id}"
  instance_type               = "${var.dockercluster_instance_type}"
  subnet_id                   = "${element(data.terraform_remote_state.baseInfra.subnet_ids_backend,count.index)}"
  associate_public_ip_address = "false"
  key_name                    = "${local.resource_prefix}key"
  user_data                   = "${data.template_file.installscript_worker_intern.rendered}"

  vpc_security_group_ids = [
    "${lookup(data.terraform_remote_state.baseInfra.secgroups,"ssh_bastion_in")}",
    "${aws_security_group.SG_DockerSocket_IN_from_Bastionhost.id}",
    "${aws_security_group.SG_DockerSwarmCom_from_backendtiersubnets.id}",
  ]

  depends_on = [
    "aws_security_group.SG_DockerSocket_IN_from_Bastionhost",
    "aws_security_group.SG_DockerSwarmCom_from_backendtiersubnets",
    "aws_instance.internerDockerhostMaster",
    "aws_route53_record.dockerhost_masterintern",
  ]

  lifecycle {
    ignore_changes        = ["tags.tf_created"]
    create_before_destroy = "true"
  }

  tags = "${merge(local.common_tags,
            map(
              "Name", "${local.resource_prefix}DockerClusterWorkerIntern-${count.index}"
              )
              )}"
}

resource "aws_instance" "externerDockerhostWorker" {
  count                       = "${var.DmzDockerCluster_deploy ? length(data.terraform_remote_state.baseInfra.subnet_ids_dmz) : 0}"
  ami                         = "${data.aws_ami.dockerhostPackerAmi.id}"
  instance_type               = "${var.dockercluster_instance_type}"
  subnet_id                   = "${element(data.terraform_remote_state.baseInfra.subnet_ids_dmz,count.index)}"
  associate_public_ip_address = "true"
  key_name                    = "${local.resource_prefix}key"
  user_data                   = "${data.template_file.installscript_worker_extern.rendered}"

  vpc_security_group_ids = [
    "${lookup(data.terraform_remote_state.baseInfra.secgroups,"ssh_bastion_in")}",
    "${aws_security_group.SG_DockerSocket_IN_from_Bastionhost.id}",
    "${aws_security_group.SG_DockerSwarmCom_from_dmztiersubnets.id}",
  ]

  depends_on = [
    "aws_security_group.SG_DockerSocket_IN_from_Bastionhost",
    "aws_security_group.SG_DockerSwarmCom_from_dmztiersubnets",
    "aws_instance.externerDockerhostMaster",
    "aws_route53_record.dockerhost_masterextern",
  ]

  lifecycle {
    ignore_changes        = ["tags.tf_created"]
    create_before_destroy = "true"
  }

  tags = "${merge(local.common_tags,
            map(
              "Name", "${local.resource_prefix}DockerClusterWorkerExtern-${count.index}"
              )
              )}"
}
