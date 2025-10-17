aws_region       = "us-east-1"
cluster_version  = "1.33"
eks_cluster_name = "my-fargate-cluster"
vpc_name         = "eks-fargate-vpc"
vpc_cidr         = "10.0.0.0/16"
vpc_azs          = ["us-east-1a", "us-east-1b", "us-east-1c"]
private_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
public_subnets   = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

tags = {
  service                  = "kubernetes"
  managedby                = "terraform"
  env                      = "hlg"
  "karpenter.sh/discovery" = "my-fargate-cluster"
}