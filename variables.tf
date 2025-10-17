variable "aws_region" {
  type        = string
  description = "AWS region where the resources will be deployed (e.g., us-east-1)."
}

variable "cluster_version" {
  type        = string
  description = "EKS cluster version (e.g., 1.33)."
}

variable "eks_cluster_name" {
  type        = string
  description = "Name of the Amazon EKS cluster."
}

variable "vpc_name" {
  type        = string
  description = "Name of the VPC used for the EKS cluster."
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC (e.g., 10.0.0.0/16)."
}

variable "vpc_azs" {
  type        = list(string)
  description = "List of Availability Zones used by the VPC."
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet IDs used by internal components of the cluster."
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet IDs used by load balancers and public services."
}

variable "tags" {
  type        = map(string)
  description = "Key-value tags applied to all created AWS resources."
}
