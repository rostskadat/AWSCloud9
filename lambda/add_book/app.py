import json
import logging

import boto3

# Extract from the lambda function all costly action such as setting up a
# connection to a DB, etc...
client = boto3.client('sts')

# Use logs in order to have formatted output that can be easily parsed.
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    response = client.get_caller_identity()
    return {
        "statusCode": 200,
        "headers": {
            # In order to configure CORS while using Lambda Proxy integration 
            # it is important to add the following header (no set by
            # APIGateway... )
            # "Access-Control-Allow-Origin": "*",
            "Content-Type": "application/json" 
        },
        "body": json.dumps(response),
    }
