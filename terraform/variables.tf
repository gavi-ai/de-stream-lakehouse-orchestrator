variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS Region for Ishqa11 Data Lake"
}

variable "snowflake_account" {
  type        = string
  description = "Snowflake Account Identifier"
}

variable "snowflake_username" {
  type        = string
  description = "Snowflake Administrator Username"
}

variable "snowflake_password" {
  type        = string
  sensitive   = true
  description = "Snowflake Administrator Password"
}