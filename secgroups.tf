resource "aws_security_group" "SG_DockerSocket_IN_from_Bastionhost" {
  name        = "${local.resource_prefix}SG_DockerSocket_IN_from_Bastionhost"
  description = "Allow SSH inbound traffic from Bastionhost for Project ${lookup(local.common_tags,"tf_project_name")}"
  vpc_id      = "${data.terraform_remote_state.baseInfra.vpc_id}"

  ingress {
    from_port       = 2375
    to_port         = 2376
    protocol        = "tcp"
    security_groups = ["${data.terraform_remote_state.baseInfra.bastion_sg}"]
  }

  egress {
    from_port   = 0
    to_port     = 65534
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    ignore_changes = ["tags.tf_created"]
  }

  tags = "${merge(local.common_tags,
             map(
               "Name", "${local.resource_prefix}SG_DockerSocket_IN_from_Bastionhost"
               )
               )}"
}

resource "aws_security_group" "SG_DockerSwarmCom_from_tiersubnets" {
  name        = "${local.resource_prefix}SG_DockerSwarmCom_from_tiersubnets"
  description = "Allow Docker Swarm Communication inbound traffic from Subnets for Project ${lookup(local.common_tags,"tf_project_name")}"
  vpc_id      = "${data.terraform_remote_state.baseInfra.vpc_id}"

  ingress {
    description ="Docker Swarm cluster management"
    from_port   = 2377
    to_port     = 2377
    protocol    = "tcp"
    cidr_blocks = ["${data.terraform_remote_state.baseInfra.subnet_cidrblocks_backend}"]
  }

  ingress {
    description ="Docker Swarm communication between the nodes (TCP)"
    from_port   = 7946
    to_port     = 7946
    protocol    = "tcp"
    cidr_blocks = ["${data.terraform_remote_state.baseInfra.subnet_cidrblocks_backend}"]
  }

  ingress {
    description = "Docker Swarm communication between the nodes (UDP)"
    from_port   = 7946
    to_port     = 7946
    protocol    = "udp"
    cidr_blocks = ["${data.terraform_remote_state.baseInfra.subnet_cidrblocks_backend}"]
  }

  ingress {
    description = "Docker Overlaynetworktraffic"
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    cidr_blocks = ["${data.terraform_remote_state.baseInfra.subnet_cidrblocks_backend}"]
  }

  egress {
    from_port   = 0
    to_port     = 65534
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    ignore_changes = ["tags.tf_created"]
  }

  tags = "${merge(local.common_tags,
             map(
               "Name", "${local.resource_prefix}SG_DockerSwarmCom_from_tiersubnets"
               )
               )}"
}
