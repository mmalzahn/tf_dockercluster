output "DockerMasterDmzFqdn" {
  value = "${aws_route53_record.dockerhost_masterextern.fqdn}"
}
output "DockerMasterBackendFqdn" {
  value = "${aws_route53_record.dockerhost_masterintern.fqdn}"
}
