#APP1



##Random
resource "random_string" "random" {
  length           = 4
  special          = false
  min_lower        = 4
}

##Vars
variable "AWS_ACCOUNT_NUMBER" {}
variable "name"{
  default = "blog-creator"
} 

##LOCALS
locals {
  app_1_name = "${var.name}-${random_string.random.result}-products"
  #LAMBDA
  ##aws_lambda_function
  aws_lambda_function_app_1_function_name = "${local.app_1_name}"
  aws_lambda_function_app_1_description   = "${local.app_1_name}"
  aws_lambda_function_app_1_timeout       = 100
  ##aws_lambda_permission
  aws_lambda_permission_app_1_statement_id  = "AllowExecutionFromAPIGateway"
  aws_lambda_permission_app_1_action        = "lambda:InvokeFunction"
  aws_lambda_permission_app1_principal      = "apigateway.amazonaws.com"
  #IAM
  ##aws_iam_role
  aws_iam_role_app_1_name = "${local.app_1_name}"
  ##aws_iam_role_policy_attachment
  aws_iam_role_policy_attachment_app_1_policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ##aws_iam_policy
  aws_iam_policy_app_1_name = "${local.app_1_name}"
  aws_iam_policy_app1_path  = "/"
  aws_iam_policy_app_1_description = "${local.app_1_name}"
  #Cloudwatch
  ##aws_cloudwatch_log
  aws_cloudwatch_log_app_1_group_name = "${local.app_1_name}"
  #Dynamodb
  ##aws_dynamodb_table
  aws_dynamodb_table_app_1_db_1 = "${local.app_1_name}-main"
  aws_dynamodb_table_app_1_db_2 = "${local.app_1_name}-variants"
  aws_dynamodb_table_app_1_db_3 = "${local.app_1_name}-options"
  aws_dynamodb_table_app_1_db_4 = "${local.app_1_name}-images"
  aws_dynamodb_table_app_1_db_5 = "${local.app_1_name}-image"
  aws_dynamodb_table_app_1_db_main_hashkey = "id"
  aws_dynamodb_table_app_1_db_main_range_key = "title"
  aws_dynamodb_table_app_1_db_sup_hashkey = "id"
  aws_dynamodb_table_app_1_db_sup_range_key = "product_id"
}

##LAMBDA
resource "aws_lambda_function" "app_1" {
  function_name     = local.aws_lambda_function_app_1_function_name
  description       = local.aws_lambda_function_app_1_description
  timeout           = local.aws_lambda_function_app_1_timeout
  runtime           = "python3.9"
  handler           = "app_1.lambda_handler"
  s3_bucket         = aws_s3_bucket.app_1.id
  s3_key            = aws_s3_object.app_1.key
  source_code_hash  = data.archive_file.app_1.output_base64sha256
  role              = aws_iam_role.app_1.arn
  environment {
    variables = {
      TableName1 = local.aws_dynamodb_table_app_1_db_1
      TableName2 = local.aws_dynamodb_table_app_1_db_2
      TableName3 = local.aws_dynamodb_table_app_1_db_3
      TableName4 = local.aws_dynamodb_table_app_1_db_4
      TableName5 = local.aws_dynamodb_table_app_1_db_5
    }
  }
}

resource "aws_lambda_permission" "app_1" {
  statement_id  = local.aws_lambda_permission_app_1_statement_id
  action        = local.aws_lambda_permission_app_1_action
  function_name = aws_lambda_function.app_1.function_name
  principal     = local.aws_lambda_permission_app1_principal
}

##S3
data "archive_file" "app_1" { 
  type        = "zip"
  source_dir  = "${path.module}/app_1"
  output_path = "${path.module}/app_1.zip"
}

resource "aws_s3_bucket" "app_1" {
  bucket_prefix = local.app_1_name
  force_destroy = true
}

resource "aws_s3_object" "app_1" {
  bucket  = aws_s3_bucket.app_1.id
  key     = "app_1.zip"
  source  = data.archive_file.app_1.output_path
  etag    = filemd5(data.archive_file.app_1.output_path)
}

##IAM
resource "aws_iam_role" "app_1" {
  name = local.aws_iam_role_app_1_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "app_1" {
  role       = aws_iam_role.app_1.name
  policy_arn = local.aws_iam_role_policy_attachment_app_1_policy_arn
}

resource "aws_iam_policy" "app_1" {
    name = local.aws_iam_policy_app_1_name
    path = local.aws_iam_policy_app1_path
    description = local.aws_iam_policy_app_1_description
    policy = jsonencode(
        {
          Version = "2012-10-17"
          Statement = [
            {
              "Sid": "VisualEditor0",
              "Effect": "Allow",
              "Action": [
                  "logs:CreateLogGroup"
              ]
              "Resource": "*"
            }
          ]
        }
    )
}

resource "aws_iam_policy_attachment" "app_1" {
  name       = aws_iam_policy.app_1.name
  roles      = [aws_iam_role.app_1.name]
  policy_arn = aws_iam_policy.app_1.arn
}

##cloudwatch
resource "aws_cloudwatch_log_group" "app_1" {
  name = local.aws_cloudwatch_log_app_1_group_name
  retention_in_days = 30
}