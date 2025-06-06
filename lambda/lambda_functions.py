import json
import os
import logging
import boto3


s3_client = boto3.client('s3')
sns = boto3.client('sns') 

logger = logging.getLogger()
logger.setLevel("INFO")


BUCKET_NAME = os.environ.get("BUCKET_NAME", "event_announce")
TOPIC_ARN = os.environ.get("TOPIC_ARN", "arn placehoder")
Events_File = "events.json"


def upload_file_to_s3(bucket_name, file_name, file_content):
    try:
        s3_client.put_object(Bucket=bucket_name, Key=file_name, Body=file_content)
    except Exception as e:
        logger.error(f"Error uploading file to s3: {e}")
        raise


def create_events_handler(events, context):
    try:
        body = json.loads(events['body'])
        eventId = body['id']
        eventName = body['name']
        eventDate = body['date']

        if not (eventId and eventName and eventDate):
            return {
                'statusCode' : 400,
                'body': json.dumps({'error': 'Missing required fields: id, name, or date'})
            }
        try:
            response = s3_client.get_object(Bucket=BUCKET_NAME, Key=Events_File)
            existing_events = json.loads(response['Body'].read())
        except s3_client.exceptions.NoSuchKey:
            existing_events = []
        
        new_event = {
            'id': eventId,
            'name': eventName,
            'date': eventDate
        }

        existing_events.append(new_event)

        updated_json = json.dumps(existing_events, indent=2)
        upload_file_to_s3(BUCKET_NAME, Events_File, updated_json)

        return {
            'statusCode': 200,       
            'body': json.dumps({'message': 'Event has been successfully created'})
            }
    except Exception as e:
        logger.error(f"Error creating event: {e}")
        return {
            'statusCode': 500,
            'body' : json.dumps({'error': 'Internal server error'})
        }

