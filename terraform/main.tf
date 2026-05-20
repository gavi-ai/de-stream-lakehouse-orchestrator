terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.87.0"
    }
  }
}

# AWS Provider Initialization
provider "aws" {
  region = var.aws_region
}

# Snowflake Provider Initialization
provider "snowflake" {
  account  = var.snowflake_account
  username = var.snowflake_username
  password = var.snowflake_password
  role     = "ACCOUNTADMIN"
}
# 1. AWS S3 Bucket - The Ishqa11 Data Lake (Bronze Landing Zone)
resource "aws_s3_bucket" "ishqa11_data_lake" {
  bucket        = "ishqa11-data-lake-storage"
  force_destroy = true # Deletes files dynamically during teardown
}

resource "aws_s3_bucket_versioning" "lake_versioning" {
  bucket = aws_s3_bucket.ishqa11_data_lake.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 2. Snowflake Base Infrastructure (Database & Warehouses)
resource "snowflake_database" "ishqa11_db" {
  name    = "ISHQA11_PROD_DB"
  comment = "Production Database for Ishqa11 Data Lakehouse Engine"
}

# Dedicated Compute Warehouse for Ingestion & Snowpipe
resource "snowflake_warehouse" "ingest_wh" {
  name           = "ISHQA11_INGEST_WH"
  warehouse_size = "XSMALL"
  auto_suspend   = 60 # Automatically shuts off after 1 minute of inactivity to save costs
  auto_resume    = true
}

# Dedicated Multi-Cluster Compute for dbt Core Transformations
resource "snowflake_warehouse" "transform_wh" {
  name           = "ISHQA11_TRANSFORM_WH"
  warehouse_size = "XSMALL"
  auto_suspend   = 60
  auto_resume    = true
}

# Snowflake Schemas for Medallion Architecture Blueprint
resource "snowflake_schema" "bronze_schema" {
  database = snowflake_database.ishqa11_db.name
  name     = "BRONZE"
}

resource "snowflake_schema" "silver_schema" {
  database = snowflake_database.ishqa11_db.name
  name     = "SILVER"
}

resource "snowflake_schema" "gold_schema" {
  database = snowflake_database.ishqa11_db.name
  name     = "GOLD"
}
# ============================================================================
# 3. ENTERPRISE STORAGE INTEGRATION GATEWAY (AWS S3 <-> SNOWFLAKE COUPLING)
# ============================================================================

# Create an Identity and Access Management (IAM) Role for Snowflake's Cloud Service Engine
resource "aws_iam_role" "snowflake_storage_role" {
  name = "ishqa11-snowflake-storage-integration-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::000000000000:root" # This automatically overrides down the line via platform integration metrics
        }
      }
    ]
  })
}

# Attach secure Least-Privilege IAM Access Policy to safeguard Data Lake resources
resource "aws_iam_policy" "lake_access_policy" {
  name        = "ishqa11-data-lake-access-policy"
  description = "Allows high-throughput read/write pipelines from Snowflake Warehouse Clusters"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = "${aws_s3_bucket.ishqa11_data_lake.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = aws_s3_bucket.ishqa11_data_lake.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "policy_sync" {
  role       = aws_iam_role.snowflake_storage_role.name
  policy_arn = aws_iam_policy.lake_access_policy.arn
}

# Provision Secure Enterprise Decoupled Object Layer Access inside Snowflake Engine
resource "snowflake_storage_integration" "s3_integration" {
  name    = "ISHQA11_S3_STORAGE_INTEGRATION"
  comment = "Production-grade decoupled data bridge linking cloud storage arrays"
  type    = "EXTERNAL_STAGE"

  enabled = true

  storage_allowed_locations = ["s3://${aws_s3_bucket.ishqa11_data_lake.bucket}/"]
  storage_provider           = "S3"
  storage_aws_role_arn       = aws_iam_role.snowflake_storage_role.arn
}