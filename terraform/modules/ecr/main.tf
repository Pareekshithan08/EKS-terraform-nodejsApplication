resource "aws_ecr_repository" "patient-service" {
    name = var.repository_name

    image_scanning_configuration {
      scan_on_push = true
    }

    tags = {
        project = "eks-microservice"
    }
  
}