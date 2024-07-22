import boto3
import base64
import requests
import json
import datetime

# S3
s3 = boto3.client('s3')
bucket_name = 'cc-f-one-assets-07-13-24v01'
file_name = 'race_results_data.json'
path_to_file = 'data/races/' + file_name

# DynamoDB
dynamodb = boto3.resource('dynamodb') 
table_name = 'cc-f-one-race-data-db'
results_table = dynamodb.Table(table_name) 

def lambda_handler(event, context):
    print(f'{bucket_name}/{path_to_file}')
    
    # Read race_results_data.json data file from S3
    resp = s3.get_object(Bucket=bucket_name, Key=path_to_file)
    content = resp['Body']
    json_obj = json.loads(content.read())
    # print(json_obj)

    # Traverse Data
    for index, result in enumerate(json_obj):
        # print(f'\t{result}')
        year = result['year']
        grand_prix = result['grand_prix']
        date = result['date']
        winner = result['winner']
        car = result['car']
        laps = result['laps']
        elapsed_time = result['time']
        
        # Persist Data in DB
        response = results_table.put_item( 
            Item = { 
                    'RESULT_ID': str(index), 
                    'year': year,
                    'grand_prix': grand_prix,
                    'date': date,
                    'winner': winner,
                    'car': car,
                    'laps': laps,
                    'time': elapsed_time,
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