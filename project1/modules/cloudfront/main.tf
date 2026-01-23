resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = var.bucket_domain_name
    origin_id   = "S3-${var.bucket_domain_name}"

    s3_origin_config {
      origin_access_identity = var.oai_id
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.comment
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.bucket_domain_name}"

    cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"  # AWS Managed CachingOptimized

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  dynamic "logging_config" {
    for_each = var.enable_logging ? [1] : []
    content {
      include_cookies = false
      bucket          = var.logging_bucket
      prefix          = "${var.project_name}/${var.env}/"
    }
  }

  tags = var.tags
}