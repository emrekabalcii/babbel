import base64
import json
from datetime import datetime

from aws_lambda_powertools.utilities.data_classes import (
    KinesisFirehoseEvent,
    event_source,
)
from aws_lambda_powertools.utilities.typing import LambdaContext


@event_source(data_class=KinesisFirehoseEvent)
def lambda_handler(event: KinesisFirehoseEvent, context: LambdaContext):
    result = []

    for record in event.records:
        data_payload_decoded = base64.b64decode(record['data']).decode('utf-8')
        data_decoded = json.loads(data_payload_decoded)
        
        event_name = data_decoded['event_name']
        event_type = event_name.split(':', 1)
        event_subtype = event_name.split(':', 2)
        
        created_at = data_decoded['created_at']
        created_datetime = datetime.fromtimestamp(created_at).replace(microsecond=0).isoformat()
    
        
        data_decoded['event_type'] = event_type
        data_decoded['event_subtype'] = event_subtype
        data_decoded['created_datetime'] = created_datetime

        processed_record = {
            "recordId": record.record_id,
            "data": base64.b64encode(json.dumps(data_decoded).encode("utf-8")),
            "result": "Ok",
        }

        result.append(processed_record)

    # return transformed records
    return {"records": result}