import json
import os
import logging
import boto3


s3_client = boto3.client('s3')
sns = boto3.client('sns') 

logger = logging.getLogger()
logger.setLevel("INFO")


BUCKET_NAME = os.environ["BUCKET_NAME"]
TOPIC_ARN = os.environ.get("TOPIC_ARN")
Events_File = "events.json"

def build_response(status_code, body):
    return {
        'statusCode': status_code,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Allow-Methods": "OPTIONS,GET,PUT"
        },
        'body': json.dumps(body) if not isinstance(body, str) else body
    }

def upload_file_to_s3(bucket_name, file_name, file_content):
    try:
        s3_client.put_object(Bucket=bucket_name, Key=file_name, Body=file_content)
    except Exception as e:
        logger.error(f"Error uploading file to s3: {e}", exc_info=True)
        raise


def create_events_handler(events, context):

    try:
        body = json.loads(events['body'])
        eventId = body.get('id')
        eventName = body.get('name')
        eventDate = body.get('date')

        if not (eventId and eventName and eventDate):
            return build_response(400, {'error': 'Missing required fields: id, name, or date'})
        try:
            response = s3_client.get_object(Bucket=BUCKET_NAME, Key=Events_File)
            existing_events = json.loads(response['Body'].read().decode('utf-8'))
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
        
        subject = 'New Event Created'
        message = f"A new event is happening soon. {eventName} is starting on {eventDate}."

        try:
            sns.publish(
                TopicArn=TOPIC_ARN,
                Subject=subject,
                Message=message
        )     
        except Exception as e:
            logger.error(f"Error publishing to SNS: {e}", exc_info=True)
            return build_response(500, {'error' : f"Failed to publish notification: {str(e)}"})
        
        return build_response(200, {'message': 'Event has been successfully created'})
    except Exception as e:
        logger.error(f"Error creating event: {e}")
        return build_response(500, {'error': f"{str(e)}"})

#   
def subscription_exists(topic_arn, email):
    paginator = sns.get_paginator('list_subscriptions_by_topic')
    for page in paginator.paginate(TopicArn=topic_arn):
        for sub in page['Subscriptions']:
            if sub['Endpoint'] == email and sub['Protocol'] == 'email':
                return True
    return False

def subscribe_handler(events, context):
    try:
        body = json.loads(events.get('body', '{}'))
        email = body.get('email')
        if not email:
            return build_response(400, {'error': 'Email is required'})

        if not TOPIC_ARN:
            return build_response(500, {'error': 'TOPIC_ARN environment variable not set'})
        
        if subscription_exists(TOPIC_ARN, email):
            return build_response(400, {'error': 'Email has already been subscribed'})
        
        sns.subscribe(
            TopicArn=TOPIC_ARN,
            Protocol='email',
            Endpoint=email
        )

        return build_response(200, {'message': 'Subscription successful. Please check your email to confirm subscription.'})
    
    except Exception as e:
        logger.error(f"Error subscribing email: {e}", exc_info=True)
        return build_response(500, {'error': f"{str(e)}"})


def get_events_handler(events, context):
    try:
        response = s3_client.get_object(Bucket=BUCKET_NAME, Key=Events_File)
        events_data = response['Body'].read().decode('utf-8')
        return build_response(200, json.loads(events_data))

    except s3_client.exceptions.NoSuchKey:
        return build_response(200, '[]')

    except Exception as e:
        logger.error(f"Error fetching events: {e}", exc_info=True)
        return build_response(500, {'error': f"{str(e)}"})