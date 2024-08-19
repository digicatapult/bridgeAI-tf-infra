output "mlflow_s3_bucket_id" {
  value       = module.mlflow_s3_bucket[0].s3_bucket_id
}

output "mlflow_s3_bucket_arn" {
  value       = module.mlflow_s3_bucket[0].s3_bucket_arn
}
