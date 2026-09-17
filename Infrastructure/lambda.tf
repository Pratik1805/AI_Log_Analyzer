resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.project_name}_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17" 
    Statement = [{ Action = "sts:AssumeRole" 
      Effect = "Allow" 
      Principal = { Service = "lambda.amazonaws.com" } 
    }]
  })
}

resource "aws_iam_role_policy" "lambda_exec_policy" {
  name = "${var.project_name}-policy"
  role = aws_iam_role.lambda_exec_role.id
  policy = jsonencode({
    Version = "2012-10-17" 
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action = "sns:Publish",
        Effect   = "Allow",
        Resource = aws_sns_topic.pipeline_alerts.arn
      },
      {
        Action = "bedrock:InvokeModel",
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}


#Lambda function
# Automatically zip the Python file before deployment
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_function.zip"
}

# Lambda function
resource "aws_lambda_function" "log_analyer" {
  filename         = data.archive_file.lambda_zip.output_path          
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256  # <-- Triggers updates if code changes
  function_name    = var.lambda_function_name
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.10"
  timeout          = 30

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.pipeline_alerts.arn
    }
  }
}