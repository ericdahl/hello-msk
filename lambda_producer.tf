data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "lambda_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    actions = [
      "events:PutEvents",
      "kafka:DescribeCluster",
      "kafka:GetBootstrapBrokers",
      "kafka:DescribeTopic",
      "kafka:Write",
      "kafka:CreateTopic"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "lambda_policy" {
  name   = "lambda_policy"
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.lambda_policy.json
}

resource "null_resource" "build_lambda_package" {
  provisioner "local-exec" {
    command = <<EOT
      cd lambda/producer && \
      docker build -t lambda-builder . && \
      docker run --rm -v $(pwd):/app lambda-builder sh -c 'cp /lambda_function.zip /app/lambda_function.zip'
    EOT
  }

  triggers = {
    always_run = "${sha1(file("${path.module}/lambda/producer/src/main.py"))}"
  }
}

resource "aws_lambda_function" "hello_world" {
  filename         = "${path.module}/lambda/producer/lambda_function.zip"
  function_name    = "hello_world"
  role             = aws_iam_role.lambda_role.arn
  handler          = "main.handler"
  runtime          = "python3.9"
  source_code_hash = try(filebase64sha256("${path.module}/lambda/producer/lambda_function.zip"), 0)
  environment {
    variables = {
      LOG_LEVEL             = "INFO"
      MSK_BOOTSTRAP_SERVERS = "b-1.your-cluster.amazonaws.com:9092,b-2.your-cluster.amazonaws.com:9092"
      MSK_TOPIC             = "your-topic"
    }
  }

  depends_on = [null_resource.build_lambda_package]
}

resource "aws_cloudwatch_log_group" "hello_world" {
  name              = "/aws/lambda/hello_world"
  retention_in_days = 14
}

resource "aws_cloudwatch_event_rule" "every_minute" {
  name                = "every_minute"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.every_minute.name
  target_id = "lambda"
  arn       = aws_lambda_function.hello_world.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_world.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_minute.arn
}

output "lambda_function_name" {
  value = aws_lambda_function.hello_world.function_name
}

output "lambda_function_arn" {
  value = aws_lambda_function.hello_world.arn
}
