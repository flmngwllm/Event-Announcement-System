terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "willofleming-terraform-state"
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}


provider "aws" {
  region = var.REGION
}

resource "local_file" "frontend_api_config" {
  content = jsonencode({
    apiBaseUrl = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${var.REGION}.amazonaws.com/${aws_api_gateway_stage.Prod_stage.stage_name}"
  })
  filename = "${path.module}/../frontend/config.json"
}

