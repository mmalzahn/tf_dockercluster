resource "local_file" "dockerMasterInstallscript" {
  count      = "${var.debug_on ? 1 : 0 }"
  content    = "${data.template_file.installscript_master_intern.rendered}"
  filename   = "${path.module}/debug/${terraform.workspace}/dockerMasterInstallscript.txt"
  depends_on = ["aws_instance.internerDockerhostMaster"]
}
resource "local_file" "dockerWorkerInstallscript" {
  count      = "${var.debug_on ? 1 : 0 }"
  content    = "${data.template_file.installscript_worker_intern.rendered}"
  filename   = "${path.module}/debug/${terraform.workspace}/dockerWorkerInstallscript.txt"
  depends_on = ["aws_instance.internerDockerhostWorker"]
}
# resource "local_file" "" {
#   count      = "${var.debug_on ? 1 : 0 }"
#   content    = "${data.template_file.installscript_master_intern.rendered}"
#   filename   = "${path.module}/debug/${terraform.workspace}/dockerMasterInstallscript.txt"
#   depends_on = ["aws_instance.internerDockerhostMaster"]
# }
