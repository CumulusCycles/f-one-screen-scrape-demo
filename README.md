# f-one-screen-scrape
This Repo contains demo Python and Node.js Apps which screen-scrape the [F1](https://www.formula1.com/) and [F1 Academy](https://www.f1academy.com/) sites. 

Uses: Selenium, Chrome, Chromedriver, and Webdriver Manager Libraries. 

Deployemnt on both local dev machine, including ```Docker``` Continers, and on ```AWS``` (Lambda, ECS) examples included.

```AWS``` Resources provisioned via ```Terraform```.


## F1 Academy App 
These Apps (Python, Node.js) scrape the [F1 Academy](https://www.f1academy.com/) site.

- [Demo App execution videos](demo_vids)

### Local Python execution
- See [README.md](f1-academy/demo/python) in [f1-academy/demo/python](f1-academy/demo/python) folder

### Local Node.js execution
- See [README.md](f1-academy/demo/node_js) in [f1-academy/demo/node_js](f1-academy/demo/node_js) folder

### Local Docker (Node.js) execution
- See [README.md](f1-academy/demo/node_js/Docker) in [f1-academy/demo/node_js/Docker](f1-academy/demo/node_js/Docker) folder

### Local Docker (Lambda / Python) execution
- See [README.md](f1-academy/demo/lambda) in [f1-academy/demo/lambda](f1-academy/demo/lambda) folder


### AWS
```AWS``` Resources provisioned via ```Terrafornm```.

- See [README.md](f1-academy/src) in [f1-academy/src](f1-academy/src) folder

#### Lambda --> S3 --> S3 Event Trigger --> Lambda -->  DynamoDB
![Arch Diagram](img/f1_academy_arch_diagram.png?raw=true "Arch Diagram")

<hr />

## F1 App(s)
These Apps (Python, Node.js) scrape the [F1](https://www.formula1.com/) site.

- [Demo App executio videos](demo_vids)

### Local Python execution
- See [README.md](f1/demo/python) in [f1/demo/python](f1/demo/python) folder

### Local Node.js execution
- See [README.md](f1/demo/node_js) in [f1/demo/node_js](f1/demo/node_js) folder

### Local Docker (Node.js) execution
- See [README.md](f1/demo/node_js/Docker) in [f1/demo/node_js/Docker](f1/demo/node_js/Docker) folder

### Local Docker (Lambda / Python) execution
- See [README.md](f1/demo/lambda) in [f1/demo/lambda](f1/demo/lambda) folder


### AWS
```AWS``` Resources provisioned via ```Terrafornm```.

- See [README.md](f1/src) in [f1/src](f1/src) folder
### Note: There are two versions of this App:
1. Lambda (Python) --> S3 --> EventBridge --> Lambda (Python) --> DynamoDB
2. Step Function --> AWS Batch -->  ECS  (Node.js) --> S3 --> EventBridge --> Lambda (Python) --> DynamoDB

#### 1. Lambda (Python) --> S3 --> EventBridge --> Lambda (Python) --> DynamoDB
![Arch Diagram](img/f1_arch_diagram_1.png?raw=true "Arch Diagram")

#### 2. Step Function --> AWS Batch -->  ECS  (Node.js) --> S3 --> EventBridge --> Lambda (Python) --> DynamoDB
![Arch Diagram](img/f1_arch_diagram_2.png?raw=true "Arch Diagram")

## Step Function
![Arch Diagram](img/f1_step_function.png?raw=true "Step Function")


## Notes
- All data on the [F1](https://www.formula1.com/) and [F1 Academy](https://www.f1academy.com/) sites is Copyright by Formula One World Championship Limited
- If DOM structure on the F1 or F1 Academy sites change, Scrape Apps (Python and Node.js) will need to be modified
