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
resource "aws_route53_record" "dockerhost_worker_extern_single" {
  count           = "${var.DmzDockerCluster_deploy ? length(data.terraform_remote_state.baseInfra.subnet_ids_dmz): 0}"
  allow_overwrite = "true"
  depends_on      = ["aws_instance.externerDockerhostWorker"]
  name            = "dockerworker${count.index}.extern.${terraform.workspace}"
  ttl             = "60"
  type            = "A"
  records         = ["${element(aws_instance.externerDockerhostWorker.*.private_ip,count.index)}"]
  zone_id         = "${data.aws_route53_zone.dca_poc_domain.zone_id}"
}
resource "aws_route53_record" "dockerhost_workers_extern" {
  count           = "${var.DmzDockerCluster_deploy ? 1 : 0}"
  allow_overwrite = "true"
  depends_on      = ["aws_instance.externerDockerhostWorker"]
  name            = "dockerworkers.extern.${terraform.workspace}"
  ttl             = "60"
  type            = "A"
  records         = ["${aws_instance.externerDockerhostWorker.*.private_ip}"]
  zone_id         = "${data.aws_route53_zone.dca_poc_domain.zone_id}"
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
resource "aws_route53_record" "dockerhost_masterextern" {
  allow_overwrite = "true"
  depends_on      = ["aws_instance.externerDockerhostMaster"]
  name            = "docker0.extern.${terraform.workspace}"
  ttl             = "60"
  type            = "A"
  records         = ["${aws_instance.externerDockerhostMaster.private_ip}"]
  zone_id         = "${data.aws_route53_zone.dca_poc_domain.zone_id}"
}
