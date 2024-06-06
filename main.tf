provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Name       = "hello-msk"
      Repository = "https://github.com/ericdahl/hello-msk"
    }
  }
}

data "aws_default_tags" "default" {}

locals {
  name = data.aws_default_tags.default.tags["Name"]
}

resource "aws_security_group" "msk" {
  vpc_id = aws_vpc.default.id
}

resource "aws_security_group_rule" "msk_ingress_ec2" {
  from_port                = 9098
  protocol                 = "tcp"
  security_group_id        = aws_security_group.msk.id
  to_port                  = 9098
  type                     = "ingress"
  source_security_group_id = aws_security_group.ec2_debug.id
}

resource "aws_msk_serverless_cluster" "example" {
  cluster_name = local.name

  vpc_config {
    subnet_ids         = values(aws_subnet.public)[*].id
    security_group_ids = [aws_security_group.msk.id]
  }

  client_authentication {
    sasl {
      iam {
        enabled = true
      }
    }
  }
}

