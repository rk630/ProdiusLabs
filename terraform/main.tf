module "asg" {
  source = "./modules/asg"
}
module "cloudfront" {
  source = "./modules/cloudfront"
  bucket_domain_name = module.sthree.bucket_domain_name
}
module "ec2" {
  source = "./modules/ec2"
}
module "elb" {
  source = "./modules/elb"
}
module "route53" {
 source = "./modules/route53"
 route53_zone_id = module.cloudfront.route53_zone_id
 domain_name = module.cloudfront.domain_name
}
module "securitygroup" {
    source = "./modules/securitygroup"
}
module "sthree" {
  source = "./modules/sthree"
}
module "vpc" {
  source = "./modules/vpc"
}