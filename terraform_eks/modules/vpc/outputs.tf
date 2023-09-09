# modules/vpc/outputs.tf

output "vpc_id" {
  value = aws_vpc.eks-vpc.id
}

output "subnet_ids" {
  value = aws_subnet.private[*].id
}
