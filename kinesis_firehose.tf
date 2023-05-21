resource "aws_kinesis_firehose_delivery_stream" "extended_s3_stream" {
  name        = "terraform-kinesis-firehose-extended-s3"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = aws_s3_bucket.bucket.arn

    processing_configuration {
      enabled = "true"

      processors {
        type = "Lambda"

        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "${aws_lambda_function.lambda_processor.arn}:$LATEST"
        }
      }
    }

    data_format_conversion_configuration {
      input_format_configuration {
        deserializer {
          hive_json_ser_de {}
        }
      }

      output_format_configuration {
        serializer {
          parquet_ser_de {}
        }
      }

      schema_configuration {
        database_name = aws_glue_catalog_database.glue_catalog_database.name
        table_name    = aws_glue_catalog_table.glue_catalog_table.name
        role_arn      = aws_iam_role.firehose_role.arn
      }
    }
  }
}

resource "aws_iam_role" "firehose_role" {
  name               = "firehose_role"
  assume_role_policy = data.aws_iam_policy_document.firehose_assume_role.json
}

data "aws_iam_policy_document" "firehose_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_glue_catalog_database" "glue_catalog_database" {
  name = var.glue_catalog_database_name
}

resource "aws_glue_catalog_table" "glue_catalog_table" {
  name          = var.glue_catalog_table_name
  database_name = aws_glue_catalog_database.glue_catalog_database.name

  parameters = {
    "classification" = "parquet"
  }

  storage_descriptor {
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"
    location      = "s3://${aws_s3_bucket.bucket.bucket}/"

    ser_de_info {
      name                  = "JsonSerDe"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"

      parameters = {
        "serialization.format" = 1
        "explicit.null"        = false
        "parquet.compression"  = "SNAPPY"
      }
    }

    dynamic "columns" {
      for_each = var.glue_catalog_table_columns
      content {
        name = columns.value["name"]
        type = columns.value["type"]
      }
    }
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket = var.s3_bucket_path
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}