#lambda assume role
resource "aws_iam_role" "iam_for_lambda_wildrides" {
  name = "lambda-wildrides"

  assume_role_policy = jsonencode({
    "Version" = "2012-10-17"
    "Statement" = [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })
}

# IAM Policy for lambda 
resource "aws_iam_policy" "lambda_wildrides_policy" {
  name = "lambda-wildrides-policy"

  policy = jsonencode({
    "Version" = "2012-10-17"
    "Statement" = [
      {
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : [
          "dynamodb:BatchGet*",
          "dynamodb:DescribeStream",
          "dynamodb:DescribeTable",
          "dynamodb:Get*",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchWrite*",
          "dynamodb:CreateTable",
          "dynamodb:Delete*",
          "dynamodb:Update*",
          "dynamodb:PutItem"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:dynamodb:*:*:table/Rides"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda-attach" {
  role       = aws_iam_role.iam_for_lambda_wildrides.name
  policy_arn = aws_iam_policy.lambda_wildrides_policy.arn
}

#Data source to zip lambda
data "archive_file" "my_lambda_function" {
  source_dir  = "${path.module}/lambda/"
  output_path = "${path.module}/lambda/lambda.zip"
  type        = "zip"
}

#Lambda function
resource "aws_lambda_function" "request_rides" {
  filename         = data.archive_file.my_lambda_function.output_path
  source_code_hash = data.archive_file.my_lambda_function.output_base64sha256
  function_name    = "requestUnicorn"
  role             = aws_iam_role.iam_for_lambda_wildrides.arn
  handler          = "requestUnicorn.handler"
  runtime          = "nodejs14.x"
}

#Allowing API Gateway to Access Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "requestUnicorn"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.wild_rydes.execution_arn}/*/*/*"
}

