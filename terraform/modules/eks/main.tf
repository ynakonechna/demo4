locals {
  eks_subnets_private_tags = tomap({
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = 1
  })
  eks_subnets_public_tags = tomap({
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = 1
  })
  //public_subnet_ids = join(",", [for s in aws_subnet.public.*.id : s])
}

data "aws_eks_cluster" "cloud_tech_demo" {
  name = aws_eks_cluster.cloud_tech_demo.name
}

data "aws_eks_cluster_auth" "cloud_tech_demo" {
  name = aws_eks_cluster.cloud_tech_demo.name
}

# KMS Key
resource "aws_kms_key" "cloud_tech_demo" {
  description         = "KMS key for Cloud Tech Demo"
  enable_key_rotation = true

  tags = merge(var.cloud_tech_demo_tags, tomap({ "Name" = "cloud-tech-demo-kms-key" }))
}

resource "aws_eks_cluster" "cloud_tech_demo" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cloud_tech_demo.arn
  version  = "1.23"

  vpc_config {
    subnet_ids              = var.public_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
    security_group_ids      = [aws_security_group.eks_api_private_access.id]
  }

  encryption_config {
    provider {
      key_arn = aws_kms_key.cloud_tech_demo.arn
    }
    resources = ["secrets"]
  }

  # enabled_cluster_log_types = [ "api" ]

  tags = merge(var.cloud_tech_demo_tags, tomap({ "Name" = var.cluster_name }))

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.cloud_tech_demo_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cloud_tech_demo_AmazonEKSVPCResourceController,
  ]
}

# Security group
resource "aws_security_group" "eks_api_private_access" {
  name   = "eks-api-private-access"
  vpc_id = var.vpc_id

  tags = merge(var.cloud_tech_demo_tags, tomap({ "Name" = "eks-api-private-access" }))
}

resource "aws_security_group_rule" "inbound_rule_allow_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.eks_api_private_access.id
}

resource "aws_security_group_rule" "outbound_rule_allow_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_api_private_access.id
}

# IAM ROLE FOR EKS CLUSTER
data "aws_iam_policy_document" "cloud_tech_demo_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cloud_tech_demo" {
  name               = "eks-cluster-${var.cluster_name}"
  assume_role_policy = data.aws_iam_policy_document.cloud_tech_demo_role_policy.json

  tags = merge(var.cloud_tech_demo_tags, tomap({ "Name" = "eks-cluster-${var.cluster_name}" }))
}

resource "aws_iam_role_policy_attachment" "cloud_tech_demo_AmazonEKSClusterPolicy" {
  role       = aws_iam_role.cloud_tech_demo.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "cloud_tech_demo_AmazonEKSVPCResourceController" {
  role       = aws_iam_role.cloud_tech_demo.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

# ADD TAGS FOR PRIMARY EKS SG
resource "aws_ec2_tag" "cluster_primary_security_group" {
  for_each = var.cloud_tech_demo_tags

  resource_id = aws_eks_cluster.cloud_tech_demo.vpc_config[0].cluster_security_group_id
  key         = each.key
  value       = each.value

  depends_on = [
    aws_eks_cluster.cloud_tech_demo
  ]
}

# Node
resource "aws_eks_node_group" "cloud_tech_demo_node" {
  cluster_name    = aws_eks_cluster.cloud_tech_demo.name
  node_group_name = "cloud_tech_demo_node"
  node_role_arn   = aws_iam_role.cloud_tech_demo_node.arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = ["t3.small"]

  scaling_config {
    desired_size = 2
    max_size     = 5
    min_size     = 2
  }

  update_config {
    max_unavailable = 2
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.cloud_tech_demo_node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.cloud_tech_demo_node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.cloud_tech_demo_node-AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_iam_role" "cloud_tech_demo_node" {
  name = "eks-node-group-cloud-tech-demo"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "cloud_tech_demo_node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.cloud_tech_demo_node.name
}

resource "aws_iam_role_policy_attachment" "cloud_tech_demo_node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.cloud_tech_demo_node.name
}

resource "aws_iam_role_policy_attachment" "cloud_tech_demo_node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.cloud_tech_demo_node.name
}

#ADD-ONS
resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.cloud_tech_demo.name
  addon_name   = "vpc-cni"

  lifecycle {
    ignore_changes = [
      modified_at
    ]
  }

  tags = merge(var.cloud_tech_demo_tags, tomap({ "Name" = "vpc-cni" }))

  depends_on = [
    aws_eks_node_group.cloud_tech_demo_node
  ]
}

resource "aws_eks_addon" "coredns" {
  cluster_name      = aws_eks_cluster.cloud_tech_demo.name
  addon_name        = "coredns"
  resolve_conflicts = "OVERWRITE"

  lifecycle {
    ignore_changes = [
      modified_at
    ]
  }

  tags = merge(var.cloud_tech_demo_tags, tomap({ "Name" = "coredns" }))

  depends_on = [
    aws_eks_node_group.cloud_tech_demo_node
  ]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name      = aws_eks_cluster.cloud_tech_demo.name
  addon_name        = "kube-proxy"
  resolve_conflicts = "OVERWRITE"

  lifecycle {
    ignore_changes = [
      modified_at
    ]
  }

  tags = merge(var.cloud_tech_demo_tags, tomap({ "Name" = "kube-proxy" }))

  depends_on = [
    aws_eks_node_group.cloud_tech_demo_node
  ]
}

#IAM ROLE FOR SERVICE ACCOUNT
data "tls_certificate" "cloud_tech_demo" {
  url = aws_eks_cluster.cloud_tech_demo.identity[0].oidc[0].issuer

  depends_on = [
    aws_eks_cluster.cloud_tech_demo,
    aws_security_group_rule.inbound_rule_allow_https
  ]
}

data "aws_iam_policy_document" "cloud_tech_demo_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.cloud_tech_demo.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.cloud_tech_demo.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.cloud_tech_demo.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_openid_connect_provider" "cloud_tech_demo" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cloud_tech_demo.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.cloud_tech_demo.identity[0].oidc[0].issuer

  tags = merge(var.cloud_tech_demo_tags, tomap({ "Name" = "cloud-tech-demo" }))
}