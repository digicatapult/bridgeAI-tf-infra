output "bucket_id" {
  value       = [for s in module.s3_bucket : s.bucket_id]
}

output "bucket_arn" {
  value       = [for s in module.s3_bucket : s.bucket_arn]
}
