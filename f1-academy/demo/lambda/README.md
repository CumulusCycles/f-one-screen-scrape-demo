# Local Dev Machine test App in Docker Container
## Pre-reqs
- Docker must be installed on your local machine

## Steps
1. Launch Docker

2. Build Image
```
docker build --platform linux/amd64 -t scrape:1 .
docker run --platform linux/amd64 --name scrape -p 9000:8080 scrape:1
```

3. Test
```
curl "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{}'
```
