FROM python:3.9-slim

# Install zip utility
RUN apt-get update && apt-get install -y zip

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY src/ .

# Create the zip file during the build process
RUN zip -r /lambda_function.zip .
