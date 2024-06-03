#!/bin/bash

# Variables
LOCAL_DIRECTORY="/home/ec2-user"
S3_BUCKET="s3://pfastsync"
AWS_PROFILE="fastsync"  # Optional: If you use multiple AWS profiles

# Check if the local directory exists
if [ ! -d "$LOCAL_DIRECTORY" ]; then
  echo "Local directory $LOCAL_DIRECTORY does not exist."
  exit 1
fi

# Copy local directory to S3 bucket
if [ -z "$AWS_PROFILE" ]; then
  echo 'we cannot use default profile.'
  exit 1
else
  aws s3 cp "$LOCAL_DIRECTORY" "$S3_BUCKET" --recursive --profile "$AWS_PROFILE"
fi

# Check if the copy command was successful
if [ $? -eq 0 ]; then
  echo "Directory $LOCAL_DIRECTORY successfully copied to $S3_BUCKET."
else
  echo "Failed to copy directory $LOCAL_DIRECTORY to $S3_BUCKET."
fi
