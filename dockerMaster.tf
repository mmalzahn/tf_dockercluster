resource "aws_instance" "internerDockerhostMaster" {
  ami                         = "${data.aws_ami.dockerhostPackerAmi.id}"
  instance_type               = "${var.dockercluster_instance_type}"
  subnet_id                   = "${element(data.terraform_remote_state.baseInfra.subnet_ids_backend,0)}"
  associate_public_ip_address = "false"
  key_name                    = "${local.resource_prefix}key"
  user_data                   = "${data.template_file.installscript_master_intern.rendered}"

  vpc_security_group_ids = [
    "${lookup(data.terraform_remote_state.baseInfra.secgroups,"ssh_bastion_in")}",
    "${aws_security_group.SG_DockerSocket_IN_from_Bastionhost.id}",
    "${aws_security_group.SG_DockerSwarmCom_from_backendtiersubnets.id}",
  ]

  depends_on = [
    "aws_security_group.SG_DockerSocket_IN_from_Bastionhost",
    "aws_security_group.SG_DockerSwarmCom_from_backendtiersubnets",
  ]

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
resource "aws_instance" "externerDockerhostMaster" {
  ami                         = "${data.aws_ami.dockerhostPackerAmi.id}"
  instance_type               = "${var.dockercluster_instance_type}"
  subnet_id                   = "${element(data.terraform_remote_state.baseInfra.subnet_ids_dmz,0)}"
  associate_public_ip_address = "true"
  key_name                    = "${local.resource_prefix}key"
  user_data                   = "${data.template_file.installscript_master_extern.rendered}"

  vpc_security_group_ids = [
    "${lookup(data.terraform_remote_state.baseInfra.secgroups,"ssh_bastion_in")}",
    "${aws_security_group.SG_DockerSocket_IN_from_Bastionhost.id}",
    "${aws_security_group.SG_DockerSwarmCom_from_dmztiersubnets.id}",
  ]

  depends_on = [
    "aws_security_group.SG_DockerSocket_IN_from_Bastionhost",
    "aws_security_group.SG_DockerSwarmCom_from_dmztiersubnets",
  ]

  lifecycle {
    ignore_changes        = ["tags.tf_created"]
    create_before_destroy = "true"
  }

  tags = "${merge(local.common_tags,
            map(
              "Name", "${local.resource_prefix}DockerClusterMasterExtern"
              )
              )}"
}