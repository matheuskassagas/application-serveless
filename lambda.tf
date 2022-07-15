resource "null_resource" "build_lambda_layer" { # # build lambda layer
  triggers = {
    layer_build = filemd5("${local.layers_path}/package.json") # # ouvindo o arquivo para qualquer alteracao que houver
  }
  # # toda vez que houver uma alteracao ele dispara o provisioner "local-exec"

  provisioner "local-exec" {
    working_dir = local.layers_path
    command     = "npm install --production && cd ../ && zip -9 -r --quiet ${local.layer_name} *"
  }
}

resource "aws_lambda_layer_version" "joi" {
  layer_name  = "joi-layer"
  description = "joi: 17.3.0"
  filename    = "${local.layers_path}./${local.layer_name}"
  runtime     = ["nodejs14.x"]

  depends_on = [
    null_resource.build_lambda_layer
  ]
}

data "archive_file" "s3" {
  type        = "zip"
  source_file = "${local.lambdas_path}/s3/index.js"
  output_path = "files/s3-artefact.zip" # # It will create a file from src_file path at output_path path
}

resource "aws_lambda_function" "s3" {
  function_name = "s3"
  handler       = "index.handler"
  role          = aws_iam_role.s3.arn # # role, for to be able to communicate with other services from aws
  runtime       = "nodejs14.x"

  filename         = data.archive_file.s3.output_path
  source_code_hash = data.archive_file.s3.output_base64sha256

  layers = [aws_lambda_layer_version.joi.arn]

  tags = local.common_tags
}

data "archive_file" "dynamo" {
  type        = "zip"
  source_file = "${local.lambdas_path}/dynamo/index.js"
  output_path = "files/dynamo-artefact.zip" # # It will create a file from src_file path at output_path path
}

resource "aws_lambda_function" "dynamo" {
  function_name = "dynamo"
  handler       = "index.handler"
  role          = aws_iam_role.dynamo.arn # # role, for to be able to communicate with other services from aws
  runtime       = "nodejs14.x"

  filename         = data.archive_file.dynamo.output_path
  source_code_hash = data.archive_file.dynamo.output_base64sha256

  timeout     = 30
  memory_size = 128

  environment {
    variables = {
      TABLE = aws_dynamodb_table.this.name
    }
  }

  tags = local.common_tags
}