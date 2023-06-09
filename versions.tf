terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }

    snowflake = {
      source = "Snowflake-Labs/snowflake"
      version = "0.64.0"
    }
    
    archive = {
      source = "hashicorp/archive"
      version = "2.3.0"
    }
  }
}