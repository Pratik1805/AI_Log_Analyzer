resource "aws_apigatewayv2_api" "webhook_api" {
    name = var.api_gateway_name
    protocol_type = "HTTP"
}

#connect api gateway to lambda function
resource "aws_apigatewayv2_integration" "lambda_integration" {
    api_id = aws_apigatewayv2_api.webhook_api.id
    integration_type = "AWS_PROXY"
    integration_uri = aws_lambda_function.log_analyer.invoke_arn
}

# create a route to send request to lambda
resource "aws_apigatewayv2_route" "webhook_route" {
    api_id = aws_apigatewayv2_api.webhook_api.id
    route_key = "POST /webhook"
    target = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# stage
resource "aws_apigatewayv2_stage" "default_stage" {
    api_id = aws_apigatewayv2_api.webhook_api.id
    name = "$default"
    auto_deploy = true
}

# IAM permission for API Gateway to invoke Lambda function
resource "aws_lambda_permission" "api_gw_permission"{
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.log_analyer.function_name
    principal = "apigateway.amazonaws.com"
    source_arn = "${aws_apigatewayv2_api.webhook_api.execution_arn}/*/*"
}