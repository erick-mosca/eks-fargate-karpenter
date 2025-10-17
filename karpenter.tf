################################################################################
# Controller & Node IAM roles, SQS Queue, Eventbridge Rules
################################################################################

module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 20.24"

  cluster_name          = module.eks.cluster_name
  enable_v1_permissions = true
  namespace             = "karpenter"

  node_iam_role_use_name_prefix = false

  create_pod_identity_association = false
  enable_irsa                     = true
  irsa_oidc_provider_arn          = module.eks.oidc_provider_arn
}

################################################################################
# Helm charts
################################################################################

resource "helm_release" "karpenter" {
  depends_on       = [module.eks, module.karpenter]
  name             = "karpenter"
  namespace        = "karpenter"
  create_namespace = true
  repository       = "oci://public.ecr.aws/karpenter"
  chart            = "karpenter"
  version          = "1.6.3"

  values = [
    yamlencode({
      dnsPolicy = "Default"
      settings = {
        clusterName           = module.eks.cluster_name
        clusterEndpoint       = module.eks.cluster_endpoint
        interruptionQueueName = module.karpenter.queue_name
        featureGates = {
          spotToSpotConsolidation = true
        }
      }
      serviceAccount = {
        annotations = {
          "eks.amazonaws.com/role-arn" = module.karpenter.iam_role_arn
        }
      }
      controller = {
        env = [
          {
            name  = "AWS_REGION"
            value = var.aws_region
          }
        ]
      }
      webhook = {
        enabled = false
      }
    })
  ]

  lifecycle {
    ignore_changes = [
      repository_password
    ]
  }
}

resource "kubectl_manifest" "karpenter_services_ec2_node_class" {
  yaml_body = <<YAML
apiVersion: karpenter.k8s.aws/v1
kind: EC2NodeClass
metadata:
  name: services
spec:
  role: ${module.karpenter.node_iam_role_name}
  amiFamily: AL2023
  amiSelectorTerms:
    - alias: al2023@latest
  securityGroupSelectorTerms:
  - tags:
      karpenter.sh/discovery: ${var.eks_cluster_name}
  subnetSelectorTerms:
  - tags:
      karpenter.sh/discovery: ${var.eks_cluster_name}
  blockDeviceMappings:
  - deviceName: /dev/xvda
    ebs:
      volumeSize: 30Gi
      volumeType: gp3
      iops: 3000
      encrypted: true
      deleteOnTermination: true
      throughput: 125
  tags:
    KarpenterNodePoolName: services
    NodeType: services
    karpenter.sh/discovery: ${var.eks_cluster_name}
    Name: eks-services-karpenter
    terminate: "true"
YAML
  depends_on = [
    helm_release.karpenter
  ]
}

resource "kubectl_manifest" "karpenter_services_node_pool" {
  yaml_body = <<YAML
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: services 
spec:  
  template:
    metadata:
      labels:
        karpenter: Exists
        services: Exist
        apps: Exist
    spec:
      limits:
        cpu: "0"
      kubelet:
        maxPods: 110
      requirements:
        - key: kubernetes.io/arch
          operator: In
          values: ["amd64"]
        - key: "karpenter.k8s.aws/instance-category"
          operator: In
          values: ["m"]
        - key: "karpenter.k8s.aws/instance-family"
          operator: In
          values: ["m5", "m5a", "t3", "t3a", "m6i", "m6a", "m7i", "m7a"]
        - key: "karpenter.k8s.aws/instance-cpu"
          operator: In
          values: ["2"]
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["spot"]
      nodeClassRef:
        group: karpenter.k8s.aws
        kind: EC2NodeClass
        name: services
  disruption:
    consolidationPolicy: WhenEmptyOrUnderutilized
    consolidateAfter: 60s
YAML
  depends_on = [
    helm_release.karpenter
  ]
}
