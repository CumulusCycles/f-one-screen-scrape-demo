import boto3
import base64
import requests
import json
import datetime

def persistImage(s3_resource, bucket_name, url, file_name):
    response = requests.get(url)
    img = response.content
    s3_resource.Bucket(bucket_name).put_object(Key=file_name, Body=img)
    return

# S3
s3 = boto3.client('s3')
s3_resource = boto3.resource('s3')
bucket_name = 'cc-f-one-academy-assets'
file_name = 'team_data.json'
current_season = str(datetime.date.today().year)
path_to_file = current_season + '/data/' + file_name
team_assets_path = current_season + '/assets/teams/' 
driver_assets_path = current_season + '/assets/drivers/'

# DynamoDB Tables
teams_dynamodb = boto3.resource('dynamodb') 
teams_table_name = 'cc-f-one-teams-assets'
teams_table = teams_dynamodb.Table(teams_table_name) 

drivers_dynamodb = boto3.resource('dynamodb') 
drivers_table_name = 'cc-f-one-drivers-assets'
drivers_table = drivers_dynamodb.Table(drivers_table_name) 

def lambda_handler(event, context):
    # Read team_data.json data file from S3
    print('Read data from S3...')
    resp = s3.get_object(Bucket=bucket_name, Key=path_to_file)
    content = resp['Body']
    json_obj = json.loads(content.read())
    # print(json_obj)
    print('Read complete.')

    # Traverse Teams
    print('Traversing Teams...')
    for team_index, team in enumerate(json_obj):
        team_name = team['team_name']
        print(f'\t{team_name}')
        team_logo = team['team_logo']
        team_image = team['team_image']
        team_county_flag = team['team_county_flag']
        team_county_name = team['team_county_name']
        team_base_info = team['team_base_info']
        
        # Persist Team in DB
        print('Putting Team data in DB...')
        team_response = teams_table.put_item( 
            Item = { 
                    'TEAM_ID': str(team_index), 
                    'season': current_season,
                    'team_name': team_name,
                    'team_county_name': team_county_name,
                    'team_base_info': team_base_info,
                } 
        ) 
        print('Putting Team data in DB done..')

        # Store Team Images
        print('Putting Team Images in S3...')
        formatted_team_name = team_name.replace(' ', '_')
        persistImage(s3_resource, bucket_name, team_image, team_assets_path + 'images/' + formatted_team_name + '_img.png')
        persistImage(s3_resource, bucket_name, team_logo, team_assets_path + 'logos/' + formatted_team_name + '_logo.png')
        persistImage(s3_resource, bucket_name, team_county_flag, team_assets_path + 'flags/' + formatted_team_name + '_flag.png')
        print('Putting Team Images in S3 done.')

        # Traverse Team Drivers
        print(f'\tTraversing Drivers...')
        drivers_data = team['drivers_data']
        # print(f'\t{drivers_data}')
        for driver_index, driver_data in enumerate(drivers_data):
            driver_name = driver_data['driver_name']
            print(f'\tDriver: {driver_name}')
            driver_img = driver_data['driver_img']
            driver_dob = driver_data['driver_dob']
            driver_nationality = driver_data['driver_nationality']
            driver_flag = driver_data['driver_flag']
            driver_supporter = driver_data['driver_supporter']

            # Persist Team Driver in DB
            print('PuttingTeam data in DB...')
            team_driver_response = drivers_table.put_item( 
                Item = { 
                        'TEAM_ID': str(team_index) ,
                        'DRIVER_ID': str(driver_index), 
                        'season': current_season,
                        'driver_name': driver_name,
                        'driver_dob': driver_dob,
                        'driver_nationality': driver_nationality,
                        'driver_supporter': driver_supporter,
                    } 
            )
            print('Putting Team data in DB done.')

            # Store Driver Images
            print('Putting Driver data in S3...')
            formatted_driver_name = driver_name.replace('.', '_')
            formatted_driver_name = formatted_driver_name.replace(' ', '_')
            persistImage(s3_resource, bucket_name, driver_img, driver_assets_path + 'images/' + formatted_driver_name + '_img.png')
            persistImage(s3_resource, bucket_name, driver_flag,driver_assets_path + 'flags/' + formatted_driver_name + '_flag.png')
            print('Putting Driver data in S3 done.')

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

    return response
