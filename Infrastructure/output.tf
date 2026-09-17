output "jenkins_webhook_url" {
    value = "${aws_apigatewayv2_api.webhook_api.api_endpoint}/webhook"
}