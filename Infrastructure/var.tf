variable "aws_region"{
    default = "ap-south-1"
}
variable "project_name" {
  default = "AI_Pipeline_Jenkins_log_Analyzer"
  description = "value of project name"
}
variable "email_address" {
  description = "Email address for build failure alerts"
  type        = string
  default     = "jsilverhand279@gmail.com" 
}
variable "lambda_function_name" {
  default = "JenkinsLogAnalyzer"
  description = "value of lambda function name"
}
variable "api_gateway_name" {
  default = "jenkins-webhook-api"
  description = "value of api gateway name"
}