output "distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.cdn.id
}

output "domain_name" {
  description = "CloudFront domain name"
  value       = aws_cloudfront_distribution.cdn.domain_name
}