"""
AWS Lambda Function - Minecraft Server Auto-Startup
This function automatically starts your EC2 instance when someone tries to connect
"""

import json
import boto3
import time

# Configuration
INSTANCE_ID = 'i-xxxxxxxxxxxxx'  # Replace with your EC2 instance ID
REGION = 'us-east-1'  # Replace with your AWS region

ec2 = boto3.client('ec2', region_name=REGION)

def lambda_handler(event, context):
    """
    Main Lambda handler function
    Starts the EC2 instance if it's stopped
    """

    try:
        # Get instance status
        response = ec2.describe_instances(InstanceIds=[INSTANCE_ID])
        instance = response['Reservations'][0]['Instances'][0]
        state = instance['State']['Name']

        print(f"Instance {INSTANCE_ID} is currently: {state}")

        if state == 'stopped':
            # Start the instance
            print(f"Starting instance {INSTANCE_ID}...")
            ec2.start_instances(InstanceIds=[INSTANCE_ID])

            # Wait for instance to start (max 2 minutes)
            waiter = ec2.get_waiter('instance_running')
            waiter.wait(
                InstanceIds=[INSTANCE_ID],
                WaiterConfig={'Delay': 5, 'MaxAttempts': 24}
            )

            # Get the new public IP
            response = ec2.describe_instances(InstanceIds=[INSTANCE_ID])
            instance = response['Reservations'][0]['Instances'][0]
            public_ip = instance.get('PublicIpAddress', 'IP not assigned yet')

            return {
                'statusCode': 200,
                'headers': {
                    'Content-Type': 'application/json'
                },
                'body': json.dumps({
                    'message': 'Server is starting up! Please wait 1-2 minutes and try connecting again.',
                    'status': 'starting',
                    'server_ip': public_ip,
                    'estimated_wait': '60-120 seconds'
                })
            }

        elif state == 'running':
            # Instance already running
            public_ip = instance.get('PublicIpAddress', 'Unknown')

            return {
                'statusCode': 200,
                'headers': {
                    'Content-Type': 'application/json'
                },
                'body': json.dumps({
                    'message': 'Server is already running!',
                    'status': 'running',
                    'server_ip': public_ip
                })
            }

        elif state == 'pending' or state == 'starting':
            # Instance is starting
            return {
                'statusCode': 200,
                'headers': {
                    'Content-Type': 'application/json'
                },
                'body': json.dumps({
                    'message': 'Server is starting up! Please wait...',
                    'status': 'starting',
                    'estimated_wait': '30-60 seconds'
                })
            }

        else:
            # Unknown state
            return {
                'statusCode': 503,
                'headers': {
                    'Content-Type': 'application/json'
                },
                'body': json.dumps({
                    'message': f'Server is in {state} state. Please contact admin.',
                    'status': state
                })
            }

    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'message': 'Error starting server. Please contact admin.',
                'error': str(e)
            })
        }


# For testing locally
if __name__ == '__main__':
    # Test the function
    result = lambda_handler({}, None)
    print(json.dumps(result, indent=2))
