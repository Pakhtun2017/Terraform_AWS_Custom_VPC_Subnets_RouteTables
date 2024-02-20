terraform {
  backend "s3" {
    bucket = "pashtun25"
    key    = "State-Files/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "Terraform-S3-backend"
    encrypt        = true
  }
}
