variable "region" {
    description = "AWS Region"
    type        = string
    default     = "eu-west-1"
}

variable "shard_count" {
    description = "Number of shards that Kinesis Stream will use"
    type        = number
    default     = 1
}

variable "retention_period" {
    description = "Length of time data records are accessible"
    type        = number
    default     = 144
}

variable "shard_level_metrics" {
    description = "A list of shard-level CloudWatch metrics which can be enabled for the stream."
    type        = list(string)
    default = [
        "IncomingBytes",
        "OutgoingBytes"
    ]
}

variable "stream_mode" {
    description = "Specifies the capacity mode of the stream. Must be either `PROVISIONED` or `ON_DEMAND`. If `ON_DEMAND` is used, then `shard_count` is ignored."
    type        = string
    default     = "ON_DEMAND"
}

variable "s3_bucket_path" {
    description = "s3 bucket path where kinesis firehose put data."
    type        = string
    default     = "babbel_events_bucket"
}

variable "storage_input_format" {
    description = "storage input format"
    type        = string
    default     = ""
}