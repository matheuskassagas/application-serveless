locals {
  lambdas_path = "${path.module}./app/lambdas"

  common_tags = {
    Project   = "TO-DO Serverless App"
    CreatedAt = "2022-07-15"
    ManagedBy = "Terraform"
    Owner     = "Curso TF com AWS"
    Service   = var.service_name
  }
}