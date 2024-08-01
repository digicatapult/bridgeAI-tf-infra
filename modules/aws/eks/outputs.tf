output "eks_cluster_id" {
  value       = module.eks_cluster.eks_cluster_id
}

output "eks_cluster_arn" {
  value       = module.eks_cluster.eks_cluster_arn
}

output "eks_cluster_endpoint" {
  value       = module.eks_cluster.eks_cluster_endpoint
}

output "eks_cluster_certificate_authority_data" {
  value       = local.certificate_authority_data
}

output "eks_cluster_version" {
  value       = module.eks_cluster.eks_cluster_version
}

output "eks_cluster_identity_oidc_issuer" {
  value       = module.eks_cluster.eks_cluster_identity_oidc_issuer
}

output "eks_cluster_managed_security_group_id" {
  value       = module.eks_cluster.eks_cluster_managed_security_group_id
}

output "eks_cluster_ipv6_service_cidr" {
  value       = module.eks_cluster.eks_cluster_ipv6_service_cidr
}

output "eks_addons_versions" {
  value       = module.eks_cluster.eks_addons_versions
}

output "eks_node_group_role_name" {
  value       = module.eks_node_group.eks_node_group_role_name
}

output "eks_node_group_id" {
  value       = module.eks_node_group.eks_node_group_id
}

output "eks_node_group_arn" {
  value       = module.eks_node_group.eks_node_group_arn
}

output "eks_node_group_resources" {
  value       = module.eks_node_group.eks_node_group_resources
}

output "eks_node_group_status" {
  value       = module.eks_node_group.eks_node_group_status
}
