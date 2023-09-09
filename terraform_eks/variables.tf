variable "region" {
  description = "The aws region. https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html"
  type        = string
  default     = "us-east-1"
}

variable "availability_zones_count" {
  description = "The number of AZs."
  type        = number
  default     = 2
}

variable "project" {
  description = "Name to be used on all the resources as identifier. e.g. Project name, Application name"
  # description = "Name of the project deployment."
  type = string
}

variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}



variable "vpc_cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_bits" {
  description = "The number of subnet bits for the CIDR. For example, specifying a value 8 for this parameter will create a CIDR with a mask of /24."
  type        = number
  default     = 8
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    "Project"     = "TerraformEKSWorkshop"
    "Environment" = "Development"
    "Owner"       = "chandu"
  }
}


variable "public_sg_rules" {
  default = [
    {
      type        = "ingress"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      type        = "ingress"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}


variable "private_sg_rules" {
  default = [
    {
      type        = "ingress"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
    },
    {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "data_plane_sg_rules" {
  default = [
    {
      type        = "ingress"
      from_port   = 0
      to_port     = 65535
      protocol    = "-1"
      cidr_blocks = ["10.0.0.0/16"]
    },
    {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "control_plane_sg_rules" {
  default = [
    {
      type        = "ingress"
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
    },
    {
      type        = "egress"
      from_port   = 0
      to_port     = 65535
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}


variable "eks_cluster_sg_rules" {
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
  default = [
    {
      description = "Allow nodes to communicate with each other"
      from_port   = 0
      to_port     = 65535
      protocol    = "-1"
      type        = "ingress"
      source_sg   = "self"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
      from_port   = 1025
      to_port     = 65535
      protocol    = "tcp"
      type        = "ingress"
      source_sg   = "eks_cluster"
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