terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}
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

  azs            = var.azs
  public_subnet  = var.public_subnet
  private_subnet = var.private_subnet
}

module "eks" {
  source = "./modules/eks"

  cluster_name = "eks-dev-cluster"

  subnet_ids = concat(
    module.vpc.public_subnet_ids,
    module.vpc.private_subnet_ids
  )

  depends_on = [module.vpc]
}

provider "kubernetes" {
  host = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      module.eks.cluster_name
    ]
  }
}

provider "helm" {
  kubernetes {
    host  = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        module.eks.cluster_name
      ]
    }
  }
}