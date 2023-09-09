terraform {
  backend "s3" {
    bucket         = "my-bucket-ha"
    dynamodb_table = "TerraformStateLock"
    key            = "terraform-aws-eks.tfstate"
    region         = "us-west-1"
    encrypt        = true
  }
}