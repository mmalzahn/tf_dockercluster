resource "tls_private_key" "private_key_dockercluster" {
  count = "${var.aws_key_name == "" ? 1 : 0}"
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "local_file" "privateKeyFile" {
  count = "${var.aws_key_name == "" ? 1 : 0}"
  content  = "${tls_private_key.private_key_dockercluster.private_key_pem}"
  filename = "${path.module}/keys/${terraform.workspace}/${lower(random_string.projectId.result)}.key.pem"
}

resource "local_file" "publicKeyFile" {
  count = "${var.aws_key_name == "" ? 1 : 0}"
  content  = "${tls_private_key.private_key_dockercluster.public_key_pem}"
  filename = "${path.module}/keys/${terraform.workspace}/${lower(random_string.projectId.result)}.pem"
}
resource "local_file" "privateKeyFile_docker" {
  count = "${var.aws_key_name == "" ? 1 : 0}"
  content  = "${tls_private_key.private_key_dockercluster.private_key_pem}"
  filename = "${path.module}/keys/${terraform.workspace}/docker/key.pem"
}

resource "local_file" "publicKeyFile_docker" {
  count = "${var.aws_key_name == "" ? 1 : 0}"
  content  = "${tls_private_key.private_key_dockercluster.public_key_pem}"
  filename = "${path.module}/keys/${terraform.workspace}/docker/cert.pem"
}

resource "local_file" "publicKeyFileOpenSsh" {
  count = "${var.aws_key_name == "" ? 1 : 0}"
  content  = "${tls_private_key.private_key_dockercluster.public_key_openssh}"
  filename = "${path.module}/keys/${terraform.workspace}/${lower(random_string.projectId.result)}_openssh.pub"
}

resource "aws_s3_bucket_object" "uploadPubKey" {
  count = "${var.aws_key_name == "" ? 1 : 0}"
  bucket     = "${data.terraform_remote_state.baseInfra.s3PubKeyBucket_name}"
  content    = "${tls_private_key.private_key_dockercluster.public_key_openssh}"
  depends_on = ["tls_private_key.private_key_dockercluster"]
  key        = "keys/${lower(random_string.projectId.result)}.pub"
  tags       = "${local.common_tags}"

  lifecycle {
    ignore_changes = ["tags.tf_created"]
  }
}
resource "aws_key_pair" "keypairDockercluster" {
  count = "${var.aws_key_name == "" ? 1 : 0}"
  key_name = "${local.resource_prefix}key"
  public_key = "${tls_private_key.private_key_dockercluster.public_key_openssh}"
}
