import boto3
import json
import os
from botocore.exceptions import ClientError

def lambda_handler(event, context):
    # Initialize the Bedrock Runtime and SNS clients
    bedrock = boto3.client("bedrock-runtime")
    sns = boto3.client("sns")
    
    # 1. Parse the incoming Jenkins data
    body = json.loads(event.get('body', '{}'))
    job_name = body.get('job_name', 'Unknown Job')
    logs = body.get('console_logs', '')
    status = body.get('status', 'Unknown Status')
    build_url = body.get('build_url', 'No URL Provided')

    # --- SUCCESS FLOW ---
    if status == 'SUCCESS':
        sns.publish(
            TargetArn=os.environ['SNS_TOPIC_ARN'],
            Message=f"Pipeline: {job_name} completed successfully!\n\nBuild URL: {build_url}\n\nThanks and regards,\nDevOps Team",
            Subject=f"Build Succeeded: {job_name}"
        )
        return {"statusCode": 200, "body": "Success email dispatched without AI invocation."}

    # --- FAILURE FLOW ---
    prompt = f"Act as a Senior DevOps Engineer. Analyze these failed Jenkins logs and provide a root cause and a brief bulleted fix:\n\n{logs}"
    
    # 2. Format the request for the Converse API
    conversation = [
        {
            "role": "user",
            "content": [{"text": prompt}]
        }
    ]

    try:
        # 3. Invoke the Meta Llama 3 model
        response = bedrock.converse(
            modelId="meta.llama3-8b-instruct-v1:0",
            messages=conversation,
            inferenceConfig={
                "maxTokens": 250,
                "temperature": 0.5
            }
        )
        
        # Extract the response text directly from the structured output
        ai_response = response["output"]["message"]["content"][0]["text"]

        # 4. Push the result to SNS
        sns.publish(
            TargetArn=os.environ['SNS_TOPIC_ARN'], 
            Message=f"Pipeline: {job_name} failed.\n\nAI Analysis:\n{ai_response}\n\nThanks and regards,\nDevOps Team", 
            Subject=f"Build Failed: {job_name}"
        )

        return {"statusCode": 200, "body": "Failure analyzed and dispatched."}

    except ClientError as e:
        print(f"Bedrock/SNS Error: {e}")
        return {"statusCode": 500, "body": "Internal server error during analysis."}