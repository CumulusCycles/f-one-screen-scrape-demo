# Demo AWS Lambda screen-scraping App
- These Apps (Python, Node.js) scrape the [F1 Academy](https://www.f1academy.com/) site.
- ```AWS``` Resources provisioned via ```Terraform```.

- Uses
    - AWS Lambda Function (python) deployed from Docker Image in ECR (Scrape data Function)
    - AWS Lambda Function (python) with Layers (Store data Function)
    - Selenium, Chrome, Chromedriver, Webdriver Manager Libraries

## Arch Diagram
### Lambda --> S3 --> S3 Event Trigger --> Lambda -->  DynamoDB
![Arch Diagram](img/f1_academy_arch_diagram.png?raw=true "Arch Diagram")

## Provisioning Steps
1. TF: Provision ```tf-state``` module
2. TF: Add Remote State Locking
3. TF: Provision ```ecrRepo``` Module
4. Follow ```App Packaging``` section steps below
5. Docker: Build Scrape App Image and push to ECR (set: ```--platform linux/amd64```)
6. TF: Provision ```scrapeFunction``` and ```storeFunction``` Modules
7. API Gateway Endpoint: Hit Endpoint to call Scrape Lambda function (will trigger Store Lambda Function)

## App Packaging
### Scrape Function (in ```/src/app/scrape_team_data``` folder)
- Update ```bucket_name``` in ```main.py```

### Store Function (in ```/src/app/store_team_data``` folder)
- Update ```bucket_name```, ```teams_table_name``` and ```drivers_table_name``` in ```main.py```
- pip3 install requests -t requests/python/lib/python3.10/site-packages
