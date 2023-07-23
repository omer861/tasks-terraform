terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

terraform {
  backend "s3" {
    bucket = "terraformbuck861"
    key    = "tasks-terraform/terraform.tfstate"
    region = "ap-south-1"
  }
}
