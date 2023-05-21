resource "aws_iam_role" "lambda_iam" {
  name               = "lambda_iam"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "archive_file" "zip_the_python_code" {
type        = "zip"
source_file  = "lambda_enhancer.py"
output_path = "./lambda_enhancer.zip"
}

resource "aws_lambda_function" "lambda_processor" {
  filename      = "lambda_enhancer.zip"
  function_name = "firehose_lambda_processor"
  role          = aws_iam_role.lambda_iam.arn
  handler       = "lambda_enchancer.lambda_handler"
  runtime       = "python3.9"
}