################################################################################
# Cluster
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.24"

  cluster_name    = var.eks_cluster_name
  cluster_version = var.cluster_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  enable_cluster_creator_admin_permissions = true
  cluster_endpoint_public_access           = true

  cluster_addons = {
    coredns = {
      configuration_values = jsonencode({
        computeType = "Fargate"
      })
    }
    kube-proxy = {}
    vpc-cni    = {}
  }

  create_cluster_security_group = false
  create_node_security_group    = false

  fargate_profiles = {
    karpenter = {
      name       = "karpenter"
      subnet_ids = module.vpc.private_subnets
      selectors = [
        { namespace = "karpenter" }
      ]
    }

    kube-system = {
      name       = "kube-system"
      subnet_ids = module.vpc.private_subnets
      selectors = [
        { namespace = "kube-system" }
      ]
    }
  }

  fargate_profile_defaults = {
    iam_role_additional_policies = {
      extra = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
    }
  }


  tags = {
    "karpenter.sh/discovery" = "${var.eks_cluster_name}"
  }
}

################################################################################
# Metrics
################################################################################

resource "helm_release" "metrics-server" {
  depends_on = [module.eks]
  chart      = "metrics-server"
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  namespace  = "kube-system"
}