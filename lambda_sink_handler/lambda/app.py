import json
import os
import boto3

from aws_lambda_powertools import Logger
import traceback

logger = Logger()

def lambda_handler(event, context):
    try:
        logger.info("Inside the lambda handler!")
        logger.info("Event content: {0}".format(str(event)))
        return {
            "statusCode": 200
        }
    except KeyError:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Error"})
        }

