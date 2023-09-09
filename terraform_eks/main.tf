module "vpc" {
  source                   = "./modules/vpc"
  region                   = var.region
  availability_zones_count = var.availability_zones_count
  project                  = var.project
  vpc_cidr                 = var.vpc_cidr
  subnet_cidr_bits         = var.subnet_cidr_bits
  tags                     = var.tags
  public_sg_rules          = var.public_sg_rules
  private_sg_rules         = var.private_sg_rules
  data_plane_sg_rules      = var.data_plane_sg_rules
  control_plane_sg_rules   = var.control_plane_sg_rules
}

module "eks_cluster" {
  source               = "./modules/eks_cluster"
  project              = var.project
  vpc_id               = module.vpc.vpc_id
  cluster_name         = "devcluster"
  subnet_ids           = module.vpc.subnet_ids
  eks_cluster_sg_rules = var.eks_cluster_sg_rules
  eks_node_sg_rules    = var.eks_node_sg_rules
}


