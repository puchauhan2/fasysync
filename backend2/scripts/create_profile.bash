#!/bin/bash

# Function to check if a profile already exists
profile_name=${1}
profile_access_key=${2}
profile_secret_key=${3}
region=${4}

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

echo  "creating s3 bucket "
aws s3api create-bucket --bucket pfastsync --region ${region} --profile ${profile_name}