# EKS Cluster
resource "aws_eks_cluster" "devcluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn  # Changed to 'cluster' to match the IAM role resource name below

  vpc_config {
    subnet_ids = var.subnet_ids  # Use the variable here
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,  # Changed to match the IAM role policy attachment resource name below
  ]
}

# EKS Cluster IAM Role
resource "aws_iam_role" "cluster" {
  name = "${var.project}-Cluster-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# EKS Cluster IAM Role Policy Attachment
resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

# EKS Cluster Security Group
resource "aws_security_group" "eks_cluster" {
  name        = "${var.project}-cluster-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project}-cluster-sg"
  }

  dynamic "ingress" {
    for_each = [for rule in var.eks_cluster_sg_rules : rule if rule.type == "ingress"]
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol 
    }
  }

  dynamic "egress" {
    for_each = [for rule in var.eks_cluster_sg_rules : rule if rule.type == "egress"]
    content {
      description = egress.value.description
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
    }
  }
}
