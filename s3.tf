data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "website" {
  bucket = "avivhamoy-terraform-site-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "Terraform-Static-Website-AvivHamoy"
  }
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.website.id

  depends_on = [
    aws_s3_bucket_public_access_block.website
  ]

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.website.id
  key          = "index.html"
  content_type = "text/html"

  content = <<-HTML
<!DOCTYPE html>
<html>
<head>
  <title>Terraform S3 Website</title>
</head>
<body>
  <h1>Hello from Terraform!</h1>
  <p>This website was created with Terraform and AWS S3.</p>
  <p>Student: Aviv Hamoy</p>
</body>
</html>
HTML

  depends_on = [
    aws_s3_bucket_policy.public_read
  ]
}

resource "aws_s3_object" "error" {
  bucket       = aws_s3_bucket.website.id
  key          = "error.html"
  content_type = "text/html"

  content = <<-HTML
<!DOCTYPE html>
<html>
<head>
  <title>404</title>
</head>
<body>
  <h1>404 - Page Not Found</h1>
</body>
</html>
HTML

  depends_on = [
    aws_s3_bucket_policy.public_read
  ]
}
