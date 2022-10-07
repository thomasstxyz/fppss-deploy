resource "aws_eks_cluster" "example" {
  name     = "example"
  role_arn = aws_iam_role.example.arn

  vpc_config {
    subnet_ids = [aws_subnet.example1.id, aws_subnet.example2.id]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.example-AmazonEKSVPCResourceController,
  ]

  tags = {
    Name = "example"
    app = "fppss-energy"
    env = "dev"
  }
}

output "endpoint" {
  value = aws_eks_cluster.example.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.example.certificate_authority[0].data
}

locals {
  kubeconfig = templatefile("templates/kubeconfig.tftpl", {
    kubeconfig_name                   = aws_eks_cluster.example.name
    endpoint                          = aws_eks_cluster.example.endpoint
    cluster_auth_base64               = aws_eks_cluster.example.certificate_authority[0].data
    aws_authenticator_command         = "aws-iam-authenticator"
    aws_authenticator_command_args    = ["token", "-i", aws_eks_cluster.example.name]
    aws_authenticator_additional_args = []
    aws_authenticator_env_variables   = {}
  })
}

output "kubeconfig" { value = local.kubeconfig }
