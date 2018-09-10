resource "tls_private_key" "private_key_dockercluster" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "local_file" "privateKeyFile" {
  content  = "${tls_private_key.private_key_dockercluster.private_key_pem}"
  filename = "${path.module}/keys/${terraform.workspace}/${lower(random_string.projectId.result)}.key.pem"
}

resource "local_file" "publicKeyFile" {
  content  = "${tls_private_key.private_key_dockercluster.public_key_pem}"
  filename = "${path.module}/keys/${terraform.workspace}/${lower(random_string.projectId.result)}.pem"
}
resource "local_file" "privateKeyFile_docker" {
  content  = "${tls_private_key.private_key_dockercluster.private_key_pem}"
  filename = "${path.module}/keys/${terraform.workspace}/docker/key.pem"
}

resource "local_file" "publicKeyFile_docker" {
  content  = "${tls_private_key.private_key_dockercluster.public_key_pem}"
  filename = "${path.module}/keys/${terraform.workspace}/docker/cert.pem"
}

resource "local_file" "publicKeyFileOpenSsh" {
  content  = "${tls_private_key.private_key_dockercluster.public_key_openssh}"
  filename = "${path.module}/keys/${terraform.workspace}/${lower(random_string.projectId.result)}_openssh.pub"
}

resource "aws_s3_bucket_object" "uploadPubKey" {
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
  count   = 1
  key_name = "${data.template_file.awskeyname.rendered}"
  public_key = "${tls_private_key.private_key_dockercluster.public_key_openssh}"
}

data "template_file" "awskeyname" {
  template = "${local.resource_prefix}${terraform.workspace}-dockercluster"
}