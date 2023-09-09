# EKS Node Groups
resource "aws_eks_node_group" "this" {
  cluster_name    = var.cluster_name  # Changed to a variable
  node_group_name = var.project
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.subnet_ids  # Changed to a variable

  scaling_config {
    desired_size = 2
    max_size     = 5
    min_size     = 1
  }

  ami_type       = "AL2_x86_64"
  capacity_type  = "ON_DEMAND"
  disk_size      = 20
  instance_types = ["t2.medium"]

  tags = merge(
    var.tags
  )

  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
  ]
}


# EKS Node IAM Role
resource "aws_iam_role" "node" {
  name = "${var.project}-Worker-Role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}


# EKS Node Security Group
resource "aws_security_group" "eks_nodes" {
  name        = "${var.project}-node-sg"
  description = "Security group for all nodes in the cluster"
  vpc_id      = var.vpc_id  # Make sure this variable is declared and passed

  tags = {
    Name                                           = "${var.project}-node-sg"
    "kubernetes.io/cluster/${var.project}-cluster" = "owned"
  }

  dynamic "ingress" {
    for_each = [for rule in var.eks_node_sg_rules : rule if rule.type == "ingress"]
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      
    }
  }

  dynamic "egress" {
    for_each = [for rule in var.eks_node_sg_rules : rule if rule.type == "egress"]
    content {
      description = egress.value.description
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
}
