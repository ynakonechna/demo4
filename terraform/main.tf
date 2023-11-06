module "network" {
    source = "./modules/network"  
    vpc_cidr_block = var.vpc_cidr
    tags = var.tags
    public_subnets = var.public_subnets
    private_subnets = var.private_subnets
}

module "rds" {
    source = "./modules/rds"
    tags = var.tags
    subnet_ids = module.network.private_subnet_ids
    vpc_id = module.network.vpc_id
    vpc_cidr_block = module.network.vpc_cidr_block
    db_name = var.db_name
    db_username = var.db_username

    depends_on = [ module.network ]
}

module "eks" {
    source = "./modules/eks"
    cloud_tech_demo_tags = var.tags
    cluster_name = var.cluster_name
    vpc_id = module.network.vpc_id
    public_subnet_ids = module.network.public_subnet_ids
    vpc_cidr = module.network.vpc_cidr_block
    private_subnet_ids = module.network.public_subnet_ids
}

module "alb_controller" {
  source = "./modules/alb_controller"
  cluster_name = var.cluster_name
  tags = var.tags
  aws_iam_openid_connect_provider_url = module.eks.aws_iam_openid_connect_provider_url
  aws_iam_openid_connect_provider_arn = module.eks.aws_iam_openid_connect_provider_arn

  depends_on = [ module.eks ]
}

module "https" {
  source       = "./modules/https"
  domain       = var.domain
}

module "app" {
  source = "./modules/app"
  certificate_arn = module.https.certificate_arn
  public_subnet_ids = module.network.public_subnet_ids

  depends_on = [ module.alb_controller, module.https ]
}

module "datadog" {
  source = "./modules/datadog"
  cluster_name = var.cluster_name

  depends_on = [ module.eks ]
}