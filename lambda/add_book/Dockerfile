FROM public.ecr.aws/lambda/python:3.7

ARG https_proxy=http://afb1linjk01p.prod.allfunds.bank:80
ENV https_proxy=$https_proxy

COPY requirements.txt .
RUN  pip3 install -r requirements.txt --target "${LAMBDA_TASK_ROOT}"
COPY app.py ${LAMBDA_TASK_ROOT}

CMD [ "app.lambda_handler" ]