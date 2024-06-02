FROM python:3.9-slim

# Install zip utility
RUN apt-get update && apt-get install -y zip

WORKDIR /app

COPY requirements.txt .
RUN pip install --target /package -r requirements.txt

COPY src/ /package/

# Create the zip file during the build process
WORKDIR /package
RUN zip -r /lambda_function.zip .
RUN #zip /lambda_function.zip main.py