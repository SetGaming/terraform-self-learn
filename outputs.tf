output "ec2_public_ip" {
  value = aws_instance.app_server.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.terraform_db.endpoint
}

output "s3_bucket_name" {
  value = aws_s3_bucket.website.id
}

output "s3_website_url" {
  value = "http://${aws_s3_bucket_website_configuration.website.website_endpoint}"
}
