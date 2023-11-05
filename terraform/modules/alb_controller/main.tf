resource "helm_release" "alb_controller" {
  count      = 1
  name       = "aws-load-balancer-controller"
  chart      = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  version    = "1.5.3"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "awsRegion"
    value = "eu-north-1"
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.aws_load_balancer_controller_role.arn
  }

  set {
    name  = "enableServiceMutatorWebhook"
    value = "false"
  }

  depends_on = [ aws_iam_role_policy_attachment.aws_load_balancer_controller_role_AWSLoadBalancerControllerIAMPolicy ]
}

#IAM ROLE FOR SERVICE ACCOUNT
data "aws_iam_policy_document" "demo_service_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(var.aws_iam_openid_connect_provider_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.aws_iam_openid_connect_provider_url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      identifiers = [var.aws_iam_openid_connect_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "aws_load_balancer_controller_role" {
  assume_role_policy = data.aws_iam_policy_document.demo_service_role_policy.json
  name               = "aws-load-balancer-controller"

  tags = merge(var.tags, tomap({ "Name" = "aws-load-balancer-controller" }))
}

resource "aws_iam_policy" "ingress_policy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  path        = "/"
  description = "ALB Ingress Controller IAM Policy"
  policy      = file("modules/alb_controller/policy.json")

  tags = merge(var.tags, tomap({ "Name" = "AWSLoadBalancerControllerIAMPolicy" }))
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller_role_AWSLoadBalancerControllerIAMPolicy" {
  role       = aws_iam_role.aws_load_balancer_controller_role.name
  policy_arn = aws_iam_policy.ingress_policy.arn
}