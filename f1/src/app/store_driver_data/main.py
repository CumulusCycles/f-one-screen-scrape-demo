import boto3
import base64
import requests
import json
import datetime

# S3
s3 = boto3.client('s3')
bucket_name = 'cc-f-one-assets-07-13-24v01'
file_name = 'driver_results_data.json'
path_to_file = 'data/drivers/' + file_name

# DynamoDB
dynamodb = boto3.resource('dynamodb') 
table_name = 'cc-f-one-driver-data-db'
results_table = dynamodb.Table(table_name) 

def lambda_handler(event, context):
    print(f'{bucket_name}/{path_to_file}')
    
    # Read driver_results_data.json data file from S3
    resp = s3.get_object(Bucket=bucket_name, Key=path_to_file)
    content = resp['Body']
    json_obj = json.loads(content.read())
    # print(json_obj)

    # Traverse Data
    for index, result in enumerate(json_obj):
        # print(f'\t{result}')
        year = result['year']
        driver_pos = result['driver_pos']
        driver_name = result['driver_name']
        nationality = result['nationality']
        car = result['car']
        pts = result['pts']
        
        # Persist Data in DB
        response = results_table.put_item( 
            Item = { 
                    'RESULT_ID': str(index), 
                    'year': year,
                    'driver_pos': driver_pos,
                    'driver_name': driver_name,
                    'nationality': nationality,
                    'car': car,
                    'pts': pts,
                } 
        ) 

    body = {
        "data": json_obj
    }

    response = {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps(body)
    }

    print(response)
    return response
