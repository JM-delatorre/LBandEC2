terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.43.0"
    }
  }
}

provider "aws" {
  region                   = "us-east-1"
  # Uncomment the following lines to use AWS shared credentials 
  # shared_credentials_files = ["~/.aws/credentials"]
  # profile                  = "terraform-user"
}