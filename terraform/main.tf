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

module "ecs" {
    source = "./modules/ecs"
    tags = var.tags
    vpc_id = module.network.vpc_id
    subnet_ids = module.network.private_subnet_ids
    public_subnets_ids = module.network.public_subnet_ids
    db_secret_arm = module.rds.db_secret_arm
    certificate_arn = module.https.certificate_arn

    depends_on = [ module.rds, module.https ]
}

module "https" {
  source       = "./modules/https"
  domain       = var.domain
}
