resource "local_file" "dockerConfig" {
  count = "${var.aws_key_name == "" ? 1 : 0}"
  content  = "${tls_private_key.private_key_dockercluster.private_key_pem}"
  filename = "${path.module}/keys/${terraform.workspace}/docker/key.pem"
}

resource "local_file" "connectSshScript" {
  content  = "${data.template_file.startSshScript.rendered}"
  filename = "${path.module}/start_ssh_connection.ps1"
}

resource "local_file" "connectDockerSocket" {
  content  = "${data.template_file.connectDockerSocket.rendered}"
  filename = "${path.module}/SetDockerconnection.ps1"
}