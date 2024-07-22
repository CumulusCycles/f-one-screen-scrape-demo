import boto3
import json

def lambda_handler(event, context):
    s3 = boto3.client('s3')
    bucket_name = "cc-f-one-assets-07-13-24v01"
    prefix = 'data/races/race_results_data.json'
    new_objects = s3.list_objects_v2(Bucket=bucket_name, Prefix=prefix)
    status_code = "200"

    if 'Contents' not in new_objects or len(new_objects['Contents']) == 0:
        status_code = "403"
        body = '{"continue": false}'
    else:
        body = '{"continue": true}'
        
    print(status_code)
    
    return {
        'statusCode': status_code,
        'body': json.dumps(body)
    }
