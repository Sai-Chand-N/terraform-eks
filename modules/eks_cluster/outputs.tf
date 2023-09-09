output "cluster_name" {
  value = aws_eks_cluster.devcluster.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.devcluster.endpoint
}

output "cluster_ca_certificate" {
  value = aws_eks_cluster.devcluster.certificate_authority[0].data
}