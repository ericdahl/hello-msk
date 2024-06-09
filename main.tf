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
  description = "allow ingress from ec2_debug"
}

resource "aws_security_group_rule" "msk_ingress_lambda_producer" {
  from_port                = 9098
  protocol                 = "tcp"
  security_group_id        = aws_security_group.msk.id
  to_port                  = 9098
  type                     = "ingress"
  source_security_group_id = aws_security_group.lambda_producer.id
  description = "allow ingress from lambda_producer"
}

resource "aws_security_group_rule" "msk_ingress_lambda_consumer" {
  from_port                = 9098
  protocol                 = "tcp"
  security_group_id        = aws_security_group.msk.id
  to_port                  = 9098
  type                     = "ingress"
  source_security_group_id = aws_security_group.lambda_consumer.id
  description = "allow ingress from lambda_consumer"
}

# shouldn't be necessary TODO
resource "aws_security_group_rule" "msk_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1" # -1 indicates all protocols
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.msk.id
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

data "aws_msk_bootstrap_brokers" "example" {
  cluster_arn = aws_msk_serverless_cluster.example.arn
}

data "aws_iam_policy_document" "assume_policy_lambda" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}