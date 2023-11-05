output "aws_iam_openid_connect_provider_url" {
    value = aws_iam_openid_connect_provider.cloud_tech_demo.url
}

output "aws_iam_openid_connect_provider_arn" {
    value = aws_iam_openid_connect_provider.cloud_tech_demo.arn
}

output "eks_endpoint" {
  value = aws_eks_cluster.cloud_tech_demo.endpoint
}

output "eks_certificate_authority" {
  value = aws_eks_cluster.cloud_tech_demo.certificate_authority[0].data
}

output "eks_auth_token" {
  value = data.aws_eks_cluster_auth.cloud_tech_demo.token
}