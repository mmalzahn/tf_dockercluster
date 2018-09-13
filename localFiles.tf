resource "local_file" "dockerConfig" {
  count = "${var.aws_key_name == "" ? 1 : 0}"
  content  = "${tls_private_key.private_key_dockercluster.private_key_pem}"
  filename = "${path.module}/keys/${terraform.workspace}/docker/key.pem"
}

resource "local_file" "connectSshInternScript" {
  content  = "${data.template_file.startSshDockerInternScript.rendered}"
  filename = "${path.module}/StartInternSshConnection.ps1"
}

resource "local_file" "connectSshExternScript" {
  content  = "${data.template_file.startSshDockerExternScript.rendered}"
  filename = "${path.module}/StartDmzSshConnection.ps1"
}
resource "local_file" "connectDockerInternSocket" {
  content  = "${data.template_file.connectDockerSocketIntern.rendered}"
  filename = "${path.module}/SetInternDockerconnection.ps1"
}
resource "local_file" "connectDockerExternSocket" {
  content  = "${data.template_file.connectDockerSocketExtern.rendered}"
  filename = "${path.module}/SetDmzDockerconnection.ps1"
}