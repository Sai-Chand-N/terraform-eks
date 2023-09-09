variable "project" {
  description = "Name to be used on all the resources as identifier, e.g., Project name, Application name."
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {
    "Project"     = "TerraformEKSWorkshop"
    "Environment" = "Development"
    "Owner"       = "chandu"
  }
}

variable "vpc_id" {
  description = "The VPC ID."
  type        = string
}

variable "eks_cluster_sg_rules" {
  description = "List of security group rules for the EKS cluster."
  type        = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    type        = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      description = "Allow worker nodes to communicate with the cluster API Server"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Allow cluster API Server to communicate with the worker nodes"
      from_port   = 1024
      to_port     = 65535
      protocol    = "tcp"
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "eks_node_sg_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    type        = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      description = "Allow nodes to communicate with each other"
      from_port   = 0
      to_port     = 65535
      protocol    = "-1"
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
      from_port   = 1025
      to_port     = 65535
      protocol    = "tcp"
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}


variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}

variable "subnet_ids" {
  description = "The IDs of the subnets where the EKS node group will be created."
  type        = list(string)
}
