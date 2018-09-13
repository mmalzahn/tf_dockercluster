resource "local_file" "dockerMasterInstallscriptExtern" {
  count      = "${var.debug_on ? 1 : 0 }"
  content    = "${data.template_file.installscript_master_extern.rendered}"
  filename   = "${path.module}/debug/${terraform.workspace}/dockerMasterInstallscriptExtern.txt"
  depends_on = ["aws_instance.externerDockerhostMaster"]
}

resource "local_file" "dockerMasterInstallscriptIntern" {
  count      = "${var.debug_on ? 1 : 0 }"
  content    = "${data.template_file.installscript_master_intern.rendered}"
  filename   = "${path.module}/debug/${terraform.workspace}/dockerMasterInstallscriptIntern.txt"
  depends_on = ["aws_instance.internerDockerhostMaster"]
}

resource "local_file" "dockerWorkerInstallscriptIntern" {
  count      = "${var.debug_on ? 1 : 0 }"
  content    = "${data.template_file.installscript_worker_intern.rendered}"
  filename   = "${path.module}/debug/${terraform.workspace}/dockerWorkerInstallscriptIntern.txt"
  depends_on = ["aws_instance.internerDockerhostWorker"]
}

resource "local_file" "dockerWorkerInstallscriptExtern" {
  count      = "${var.debug_on ? 1 : 0 }"
  content    = "${data.template_file.installscript_worker_extern.rendered}"
  filename   = "${path.module}/debug/${terraform.workspace}/dockerWorkerInstallscriptExtern.txt"
  depends_on = ["aws_instance.externerDockerhostMaster"]
}

resource "local_file" "dockerAmiId" {
  count    = "${var.debug_on ? 1 : 0 }"
  content  = "${data.aws_ami.dockerhostPackerAmi.id}"
  filename = "${path.module}/debug/${terraform.workspace}/dockerAmiId.txt"
}

resource "local_file" "projectId" {
  count    = "${var.debug_on ? 1 : 0 }"
  content  = "${random_string.projectId.result}"
  filename = "${path.module}/debug/${terraform.workspace}/projectId.txt"
}

resource "local_file" "randomPorts" {
  count    = "${var.debug_on ? 1 : 0 }"
  content  = "ssh intern: ${random_integer.randomSshPortIntern.result}\ndocker intern: ${random_integer.randomDockerPortIntern.result}\nssh extern: ${random_integer.randomSshPortExtern.result}\ndocker extern: ${random_integer.randomDockerPortExtern.result}"
  filename = "${path.module}/debug/${terraform.workspace}/randomPorts.txt"
}
