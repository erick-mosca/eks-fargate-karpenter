terraform {
  backend "s3" {
    encrypt = true
    region  = "us-east-1"
    bucket  = "terraform-state"
    key     = "eks/my-fargate-cluster/terraform.tfstate"
  }
}