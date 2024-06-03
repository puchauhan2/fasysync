#!/bin/bash

# Function to check if a profile already exists
profile_name="fastsync"
profile_access_key=${1}
profile_secret_key=${2}
region=${3}

which aws
erroCode1=${?}
    if [[ ${erroCode1} != 0 ]]; then
        echo "Please install AWS CLI"
        exit 1
    else
        echo "AWS CLI found"
    fi

profile_exists() {

    grep  "${profile_name}" ~/.aws/credentials 
    erroCode=${?}
    if [[ ${erroCode} != 0 ]]; then
        echo "Creating AWS CLI profile '${profile_name}'..."
        mkdir -p ~/.aws
        echo -e "\n[${profile_name}]" >> ~/.aws/credentials
        echo -e "aws_access_key_id = ${profile_access_key}" >> ~/.aws/credentials
        echo -e "aws_secret_access_key = ${profile_secret_key}" >> ~/.aws/credentials
        echo -e "AWS CLI profile '${profile_name}' created successfully."
        echo -e "\n[${profile_name}]" >> ~/.aws/config
        echo -e "region = ${region}"
    else
        echo "Profile already exist "
    fi
}
profile_exists


#!/bin/bash

# Variables
LOCAL_DIRECTORY=${4}
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
  aws s3 sync "$S3_BUCKET" "$LOCAL_DIRECTORY"  --profile "$AWS_PROFILE"
fi

# Check if the copy command was successful
if [ $? -eq 0 ]; then
  echo "Directory  $S3_BUCKET successfully copied to $LOCAL_DIRECTORY."
else
  echo "Failed to copy directory $S3_BUCKET to $LOCAL_DIRECTORY."
fi
