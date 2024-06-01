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