data "template_file" "installscript_worker_intern" {
  template = "${file("tpl/installdockerworker.tpl")}"

  vars {
    file_system_id = "${element(data.terraform_remote_state.baseInfra.efs_filesystem_id,0)}"
    efs_directory  = "/efs"
    project_id     = "${local.projectId}"
    master_ip      = "${aws_instance.internerDockerhostMaster.private_ip}"
  }
  depends_on =["aws_instance.internerDockerhostMaster"]
}

resource "aws_instance" "internerDockerhostWorker" {
  count         = "${var.dockercluster_deploy ? length(data.terraform_remote_state.baseInfra.subnet_ids_backend) : 0}"
  ami           = "${data.aws_ami.dockerhostPackerAmi.id}"
  instance_type = "${var.dockercluster_instance_type}"
  subnet_id     = "${element(data.terraform_remote_state.baseInfra.subnet_ids_backend,count.index)}"

  vpc_security_group_ids = [
    "${lookup(data.terraform_remote_state.baseInfra.secgroups,"ssh_bastion_in")}",
    "${aws_security_group.SG_DockerSocket_IN_from_Bastionhost.id}",
    "${aws_security_group.SG_DockerSwarmCom_from_tiersubnets.id}",
  ]

  depends_on = [
    "aws_security_group.SG_DockerSocket_IN_from_Bastionhost",
    "aws_security_group.SG_DockerSwarmCom_from_tiersubnets",
    "aws_instance.internerDockerhostMaster",
  ]

  associate_public_ip_address = "false"
  key_name                    = "${local.resource_prefix}key"
  user_data                   = "${data.template_file.installscript_worker_intern.rendered}"

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

resource "aws_route53_record" "dockerhost_worker_intern_single" {
  count           = "${var.dockercluster_deploy ? length(data.terraform_remote_state.baseInfra.subnet_ids_backend): 0}"
  allow_overwrite = "true"
  depends_on      = ["aws_instance.internerDockerhostWorker"]
  name            = "dockerworker${count.index}.intern.${terraform.workspace}"
  ttl             = "60"
  type            = "A"
  records         = ["${element(aws_instance.internerDockerhostWorker.*.private_ip,count.index)}"]
  zone_id         = "${data.aws_route53_zone.dca_poc_domain.zone_id}"
}

resource "aws_route53_record" "dockerhost_workers_intern" {
  count           = "${var.dockercluster_deploy ? 1 : 0}"
  allow_overwrite = "true"
  depends_on      = ["aws_instance.internerDockerhostWorker"]
  name            = "dockerworkers.intern.${terraform.workspace}"
  ttl             = "60"
  type            = "A"
  records         = ["${aws_instance.internerDockerhostWorker.*.private_ip}"]
  zone_id         = "${data.aws_route53_zone.dca_poc_domain.zone_id}"
}
