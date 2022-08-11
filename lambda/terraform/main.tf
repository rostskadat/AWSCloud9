locals {
  lambda_src = "${path.module}/../add_book"
  build_dir  = "${path.module}/.terraform"
  layer_dst  = "${local.build_dir}/add_book"
}

#-----------------------------------------------------------------------------
#
# DATA SECTION
#
data "aws_region" "current" {}

# NOTE: The layer code must be in the "python" folder
resource "null_resource" "lambda_dependencies" {
  provisioner "local-exec" {
    command     = <<EOT
import os
if not os.path.exists('${local.layer_dst}/python'): 
  os.makedirs('${local.layer_dst}/python')
EOT
    interpreter = ["python", "-c"]
  }
  provisioner "local-exec" {
    command = "pip3 install -r ${local.lambda_src}/requirements.txt --target ${local.layer_dst}/python"
  }
  triggers = {
    dependencies_versions = filemd5("${local.lambda_src}/requirements.txt")
    source_versions       = filemd5("${local.lambda_src}/app.py")
  }
}

resource "random_uuid" "lambda_src_hash" {
  keepers = {
    for filename in setunion(
      fileset(local.lambda_src, "requirements.txt"),
      fileset(local.lambda_src, "app.py"),
    ) :
    filename => filemd5("${local.lambda_src}/${filename}")
  }
}

data "archive_file" "layer_zip" {
  type        = "zip"
  source_dir  = local.layer_dst
  output_path = "${local.build_dir}/layer-${random_uuid.lambda_src_hash.result}.zip"
  depends_on  = [null_resource.lambda_dependencies]
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = local.lambda_src
  output_path = "${local.build_dir}/lambda-${random_uuid.lambda_src_hash.result}.zip"
  depends_on  = [null_resource.lambda_dependencies]
}

#-----------------------------------------------------------------------------
#
# RESOURCES SECTION
#
resource "aws_cloudwatch_log_group" "log_group" {
  name_prefix       = "lambda-logs"
  retention_in_days = 1
}

resource "aws_iam_role" "role" {
  name_prefix        = "add-book-role"
  description        = "The role assumed by the Lambda Function"
  assume_role_policy = file("${path.module}/iam/lambda_assume_policy.json")
}

resource "aws_iam_policy" "policy" {
  name_prefix = "add-book-policy"
  description = "The policy associated with the role assumed by the Lambda Function"
  path        = "/"
  policy = templatefile("${path.module}/iam/lambda_policy.json", {
    log_group_arn = aws_cloudwatch_log_group.log_group.arn
  })
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_lambda_layer_version" "lambda_layer" {
  layer_name          = "add-book-layer"
  filename            = data.archive_file.layer_zip.output_path
  source_code_hash    = data.archive_file.layer_zip.output_base64sha256
  compatible_runtimes = ["python3.7"]
}

resource "aws_lambda_function" "add_book" {
  function_name    = "add-book"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  role             = aws_iam_role.role.arn
  handler          = "app.lambda_handler"
  runtime          = "python3.7"
  layers           = [aws_lambda_layer_version.lambda_layer.arn]
  environment {
    variables = {
      KEY = "VALUE"
    }
  }
  timeout = 2
}