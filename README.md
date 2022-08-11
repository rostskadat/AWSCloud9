# Requirements

__NOTE__ Always use `pipenv`

# Flask

## Run test

```shell
cd flask
python3 -m unittest services.test_BookService
# or alternatively
python3 -m unittest
```

## Run app locally

```shell
cd flask
python3 -m pip install -r requirements.txt
python3 app.py
# ...
curl -v http://127.0.0.1:5000/api/books
```

# Lambda

## Create the local docker image

__Ref__: https://docs.aws.amazon.com/lambda/latest/dg/images-test.html

```shell
cd lambda/add_book
# Install Python runtime interface clients locally
python3 -m pip install awslambdaric
# build the image behind VPN
docker build --build-arg https_proxy=http://afb1linjk01p.prod.allfunds.bank:80 -t add_book:latest .
```

## Test local docker image

```shell
docker run -p 8080:8080 add_book:latest 
# ...
curl -XPOST "http://localhost:8080/2015-03-31/functions/function/invocations" -d '{}'
# ...
docker run -p 8080:8080 --env "AWS_ACCESS_KEY_ID=$Env:AWS_ACCESS_KEY_ID" --env "AWS_SECRET_ACCESS_KEY=$Env:AWS_SECRET_ACCESS_KEY" --env "AWS_SESSION_TOKEN=$Env:AWS_SESSION_TOKEN" add_book:latest 
# ...
curl -s -XPOST "http://localhost:8080/2015-03-31/functions/function/invocations" -d '{}' | jq -r .body | jq
```

## Create the AWS resources 

```shell
cd lambda/terraform
terraform init
terraform apply -auto-approve
# ...

```
