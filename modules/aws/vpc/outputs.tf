output "private_az_subnet_ids" {
  value = module.subnets.private_subnet_ids
}

output "public_az_subnet_ids" {
  value = module.subnets.public_subnet_ids
}

output "private_az_subnet_cidrs" {
  value = module.subnets.private_subnet_cidrs
}

output "public_az_subnet_cidrs" {
  value = module.subnets.public_subnet_cidrs
}

output "vpc_default_security_group_id" {
  value = module.vpc.vpc_default_security_group_id
}

output "vpc_id" {
  value = module.vpc.vpc_id
}
