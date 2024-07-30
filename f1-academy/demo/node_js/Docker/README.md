# Node.js Scrape App (Docker)

## Docker
```
docker build --platform linux/amd64 -t scrape . 
docker run --platform linux/amd64 -it -p 3000:3000  scrape 
```

## Test
```
curl http://localhost:3000
```
