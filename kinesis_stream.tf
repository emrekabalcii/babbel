resource "aws_kinesis_stream" "kinesisstream" {
    name = "babbel_kinesis_event_tracking"
    shard_count      = var.stream_mode != "ON_DEMAND" ? var.shard_count : null
    retention_period = var.retention_period

    shard_level_metrics = var.shard_level_metrics

    dynamic "stream_mode_details" {
        for_each = var.stream_mode != null ? ["true"] : []
        content {
            stream_mode = var.stream_mode
        }
    }
}