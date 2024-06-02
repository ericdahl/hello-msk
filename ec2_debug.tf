resource "aws_iam_role" "ssm_role" {
  name = "ssm_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_access" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "msk_full_access" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonMSKFullAccess"
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "ssm_instance_profile"
  role = aws_iam_role.ssm_role.name
}

resource "aws_security_group" "ec2_debug" {
  vpc_id = aws_vpc.default.id
}

resource "aws_security_group_rule" "ec2_debug_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1" # -1 indicates all protocols
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2_debug.id
}


resource "aws_instance" "example" {
  ami = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"

  instance_type = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name

  vpc_security_group_ids = [aws_security_group.ec2_debug.id]
  subnet_id = aws_subnet.public["10.0.0.0/24"].id

  lifecycle {
    ignore_changes = [ami]
  }
}

output "instance_id" {
  value = aws_instance.example.id
}
