# Demo AWS Lambda screen-scraping App
- These Apps (Python, Node.js) scrape the [F1](https://www.formula1.com/) site.
- ```AWS``` Resources provisioned via ```Terraform```.

### Note: There are two versions of this App:
1. Lambda (Python) --> S3 --> EventBridge --> Lambda (Python) --> DynamoDB
2. Step Function --> AWS Batch -->  ECS  (Node.js) --> S3 --> EventBridge --> Lambda (Python) --> DynamoDB

<hr />

## 1. Lambda (Python) --> S3 --> EventBridge --> Lambda (Python) --> DynamoDB
- Uses
    - AWS Lambda Function (python) deployed from Docker Image in ECR (Scrape data Function)
        - Uses Selenium, Chrome, Chromedriver, Webdriver Manager Libraries
        - triggered via APIGateway Endpoint
        - stores data in JSON files in S3 Bucket folders
    - AWS Lambda Functions (python) with Layers (Store data Functions)
        - triggered by EventBridge
        - stores data in DynamoDB Tables
    
## Arch Diagram
![Arch Diagram](img/f1_arch_diagram.png?raw=true "Arch Diagram")

## Provisioning Steps
1. Set ```provision_with_aws_batch``` in ```locals.tf``` == ```false```
2. TF: Provision ```tf-state``` module
3. TF: Add Remote State Locking
4. TF: Provision ```assetBucket``` Module
5. TF: Provision ```ecrRepo``` Module
6. Follow ```App Packaging``` section steps below
7. Docker: Build Scrape App Image and push to ECR (set: ```--platform linux/amd64```)
8. TF: Provision ```scrapeFunction```, ```lambdaLayer``` and ```storeFunction``` Modules
9. API Gateway Endpoint: Hit Endpoint to call Scrape Lambda function (will trigger Store Lambda Function)

## App Packaging
### Scrape Function (in ```/src/app/scrape_data_python``` folder)
- Update ```bucket_name``` in ```scrape.py```

### Store Functions (in ```/src/app/store_*_data``` folders)
- Update ```bucket_name``` and ```table_name``` in ```main.py```
- pip3 install requests -t requests/python/lib/python3.10/site-packages

<hr />

## 2. Step Function --> AWS Batch -->  ECS  (Node.js) --> S3 --> EventBridge --> Lambda (Python) --> DynamoDB
- Uses
    - AWS Batch / ECS Fargate (Node.js) deployed from Docker Image in ECR (Scrape data Function)
        - Uses Selenium, Chrome, Chromedriver, Webdriver Manager Libraries
        - triggered via Step Function
        - stores data in JSON files in S3 Bucket folders
    - AWS Lambda Functions (python) with Layers (Store data Functions)
        - triggered by EventBridge
        - stores data in DynamoDB Tables

## Arch Diagram
![Arch Diagram](img/f1_arch_diagram_2.png?raw=true "Arch Diagram")

## Step Function
![Arch Diagram](img/f1_step_function.png?raw=true "Step Function")

## Provisioning Steps
1. Set ```provision_with_aws_batch``` in ```locals.tf ```== ```true```
2. Create ```.env``` file in ```/src/app/scrape_data_node``` folder
```JavaScript
AWS_REGION="YOUR_AWS_REGION"
AWS_ACCESS_KEY="YOUR_AWS_ACCESS_KEY"
AWS_SECRET_ACCESS_KEY="YOUR_AWS_SECRET_ACCESS_KEY"
BUCKET_NAME="YOUR_S3_ASSET_BUCKET_NAME"
```
3. TF: Provision ```tf-state``` module
4. TF: Add Remote State Locking
5. TF: Provision ```assetBucket``` Module
6. TF: Provision ```ecrRepo``` Module
7. TF Provision ```dockerImageNode``` Module
8. TF Provision ```awsBatch``` Module
9. TF Provision ```stepFunction``` Module
10. Execute the following to start the Step Function
```
AWS stepfunctions start-execution --state-machine-arn STATE_MACHINE_ARN
```
11. Execute the following to hit the ECS Cluster Task Public IP
```
curl https://nnn.nnn.nnn.nnn:3000
```

### Store Functions (in ```/src/app/store_*_data``` folders)
- Update ```bucket_name``` and ```table_name``` in ```main.py```
- pip3 install requests -t requests/python/lib/python3.10/site-packages

### Step Function AWS CLI CMDs
- AWS stepfunctions start-execution --state-machine-arn YOUR_STATE_MACHINE_ARN
- AWS stepfunctions list-executions --state-machine-arn YOUR_STATE_MACHINE_ARN
- AWS stepfunctions stop-execution --execution-arn YOUR_STATE_MACHINE_EXECUTION_ARN