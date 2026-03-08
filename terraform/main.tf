provider "aws" {
  region = var.aws_region
}

module "ecr" {
    source = "./modules/ecr"

    repository_name = "patient-service"
}

module "vpc" {
  source = "./modules/vpc"
  
  vpc_name = "eks-vpc"

  vpc_cidr = "10.0.0.0/16"

  azs = [
    "us-east-1a",
    "us-east-1b"
  ]

  public_subnet = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  private_subnet = [
    "10.0.3.0/24",
    "10.0.4.0/24"
  ]
}