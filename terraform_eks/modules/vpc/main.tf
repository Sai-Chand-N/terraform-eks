# VPC
resource "aws_vpc" "eks-vpc" {
  cidr_block = var.vpc_cidr

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name   = "${var.project}-vpc",
    "kubernetes.io/cluster/${var.project}-cluster" = "shared"
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count = var.availability_zones_count

  vpc_id            = aws_vpc.eks-vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, var.subnet_cidr_bits, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name                                           = "${var.project}-public-sg"
    "kubernetes.io/cluster/${var.project}-cluster" = "shared"
    "kubernetes.io/role/elb"                       = 1
  }

  map_public_ip_on_launch = true
}

# Private Subnets
resource "aws_subnet" "private" {
  count = var.availability_zones_count

  vpc_id            = aws_vpc.eks-vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, var.subnet_cidr_bits, count.index + var.availability_zones_count)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name                                           = "${var.project}-private-sg"
    "kubernetes.io/cluster/${var.project}-cluster" = "shared"
    "kubernetes.io/role/internal-elb"              = 1
  }
}

# Internet Gateway
resource "aws_internet_gateway" "eks-igw" {
  vpc_id = aws_vpc.eks-vpc.id

  tags = {
    "Name" = "${var.project}-igw"
  }

  depends_on = [aws_vpc.eks-vpc]
}

# Route Table(s)
# Route the public subnet traffic through the IGW
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.eks-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks-igw.id
  }

  tags = {
    Name = "${var.project}-Default-rt"
  }
}

# Route table and subnet associations
resource "aws_route_table_association" "internet_access" {
  count = var.availability_zones_count

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.main.id
}

# NAT Elastic IP
resource "aws_eip" "main" {
  domain = "vpc"

  tags = {
    Name = "${var.project}-ngw-ip"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.main.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.project}-ngw"
  }
}

# Add route to route table
resource "aws_route" "main" {
  route_table_id         = aws_vpc.eks-vpc.default_route_table_id
  nat_gateway_id         = aws_nat_gateway.main.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_security_group" "public_sg" {
  name   = "${var.project}-Public-sg"
  vpc_id = aws_vpc.eks-vpc.id

  dynamic "ingress" {
    for_each = [for rule in var.public_sg_rules : rule if rule.type == "ingress"]
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = [for rule in var.public_sg_rules : rule if rule.type == "egress"]
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = {
    Name = "${var.project}-Public-sg"
  }
}

resource "aws_security_group" "private_sg" {
  name   = "${var.project}-Private-sg"
  vpc_id = aws_vpc.eks-vpc.id

  tags = {
    Name = "${var.project}-Private-sg"
  }

  dynamic "ingress" {
    for_each = [for rule in var.private_sg_rules : rule if rule.type == "ingress"]
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = [for rule in var.private_sg_rules : rule if rule.type == "egress"]
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
}


resource "aws_security_group" "data_plane_sg" {
  name   = "${var.project}-DataPlane-sg"
  vpc_id = aws_vpc.eks-vpc.id

  dynamic "ingress" {
    for_each = [for rule in var.data_plane_sg_rules : rule if rule.type == "ingress"]
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = [for rule in var.data_plane_sg_rules : rule if rule.type == "egress"]
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = {
    Name = "${var.project}-DataPlane-sg"
  }
}

resource "aws_security_group" "control_plane_sg" {
  name   = "${var.project}-ControlPlane-sg"
  vpc_id = aws_vpc.eks-vpc.id

  dynamic "ingress" {
    for_each = [for rule in var.control_plane_sg_rules : rule if rule.type == "ingress"]
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = [for rule in var.control_plane_sg_rules : rule if rule.type == "egress"]
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = {
    Name = "${var.project}-ControlPlane-sg"
  }
}