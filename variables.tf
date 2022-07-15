variable "aws_region" {
  type        = string
  description = ""
  default     = "eu-east-1"
}

variable "aws_profile" {
  type        = string
  description = ""
  default     = "default"
}

variable "aws_account_id" {
  type        = number
  description = ""
  default     = "000000000000"
}

variable "service_name" {
  type        = string
  description = ""
  default     = "To-dos"
}

variable "service_domain" {
  type        = string
  description = ""
  default     = "api-to-dos"
}