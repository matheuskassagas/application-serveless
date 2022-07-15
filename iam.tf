data "aws_iam_policy_document" "lambda-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# # --------------- S3 Role --------------- # # 
# # Integrafgir com S3, SNS e escrever logs no cloudwacth 

data "aws_iam_policy_document" "s3" { # # policy to s3
  statement {
    sid       = "AllowS3AndSNSActions" # # allow actions on s3 and SNS
    effect    = "Allow"
    resources = ["*"] # # 

    actions = [ # # actions " All of It "
      "s3:*",
      "sns:*",
    ] # # this policy say that the lambda or how use it, can execute any resource in S3 and SNS
  }

  statement { # # This block allow lambdas can invoke lambdas
    sid       = "AllowInvokingLambdas"
    effect    = "Allow"
    resources = ["arn:aws:lambda:*:*:function:*"]
    actions   = ["lambda:InvokeFunction"]
  }

  statement { # # This block allow lambdas can create groups
    sid       = "AllowCreatingLogGroups"
    effect    = "Allow"
    resources = ["arn:aws:logs:*:*:*"]
    actions   = ["logs:CreateLogGroup"]
  }

  statement { # # This block allow lambdas can write logs 
    sid       = "AllowWritingLogs"
    effect    = "Allow"
    resources = ["arn:aws:logs:*:*:log-group:/aws/lambda/*:*"]

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }
}

resource "aws_iam_role" "s3" { # # sem permicao para conversar com outro servico
  name               = "${var.service_domain}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda-assume-role.json # # assume the first role
}

resource "aws_iam_policy" "s3" { # # criando a policy utilizando o data
  name   = "${aws_lambda_function.s3.function_name}-lambda-execute-policy"
  policy = data.aws_iam_policy_document.s3.json
}

resource "aws_iam_role_policy_attachment" "s3-execute" { # # anexando a policy na role. 
  policy_arn = aws_iam_policy.s3.arn
  role       = aws_iam_role.s3.name # # lambda sera capaz de assumir a role e execultar o que a policy permite
}

# # --------------- Dynamo Role --------------- # #

data "aws_iam_policy_document" "dynamo" {
  statement {
    sid       = "AllowDynamoPermissions"
    effect    = "Allow"
    resources = ["*"]

    actions = ["dynamodb:*"]
  }

  statement {
    sid       = "AllowInvokingLambdas"
    effect    = "Allow"
    resources = ["arn:aws:lambda:*:*:function:*"]
    actions   = ["lambda:InvokeFunction"]
  }

  statement {
    sid       = "AllowCreatingLogGroups"
    effect    = "Allow"
    resources = ["arn:aws:logs:*:*:*"]
    actions   = ["logs:CreateLogGroup"]
  }

  statement {
    sid       = "AllowWritingLogs"
    effect    = "Allow"
    resources = ["arn:aws:logs:*:*:log-group:/aws/lambda/*:*"]

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }
}

resource "aws_iam_role" "dynamo" {
  name               = "dynamo-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda-assume-role.json
}

resource "aws_iam_policy" "dynamo" {
  name   = "dynamo-lambda-execute-policy"
  policy = data.aws_iam_policy_document.dynamo.json
}

resource "aws_iam_role_policy_attachment" "dynamo" {
  policy_arn = aws_iam_policy.dynamo.arn
  role       = aws_iam_role.dynamo.name
}