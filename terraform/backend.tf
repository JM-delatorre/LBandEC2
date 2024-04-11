terraform {
  backend "s3" {
    encrypt        = true
    bucket         = "epam-terraform-task"
    key            = "LBandEC2/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "TerraformLockState"
    # Uncomment the following lines to use AWS shared credentials 
    # shared_credentials_files = ["~/.aws/credentials"]
    # profile                  = "terraform-user"
  }
}