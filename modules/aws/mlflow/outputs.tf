output "bucket_id" {
  value = [for s in module.s3_bucket : s.bucket_id]
}

output "bucket_arn" {
  value = [for s in module.s3_bucket : s.bucket_arn]
}

output "policy_arn" {
  value = [for s in aws_iam_policy.this : s.arn]
}