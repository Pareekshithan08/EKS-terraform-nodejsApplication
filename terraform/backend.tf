terraform {
  backend "s3" {
    bucket = "eks-terraform-nodejsapplication-statefile"
    key = "eks/dev/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "eks-terraform-nodejsapplication-lock"
    encrypt = true
  }
}