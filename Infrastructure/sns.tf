resource "aws_sns_topic" "pipeline_alerts" {
  name = "ai-pipeline-alerts"
}
resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.pipeline_alerts.arn
  protocol = "email"
  endpoint = var.email_address
}