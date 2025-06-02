terraform {
    required_providers {
        aws = {
            source = "hashicorop/aws"
            version = "~> 5.0"
        }
    }
}

provider "aws" {
    region = "us-east-1"
  
}