#!/bin/bash

read -p "Enter the S3 bucket name: " bucket_name

# Create the modified bucket policy JSON
bucket_policy='{​​
    "Version": "2012-10-17",
    "Statement": [
        {​​
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::'"$bucket_name"'/*"
        }​​
    ]
}​​'

echo "$bucket_policy" > modified-policy.json

echo "Creating S3 bucket..."
aws s3api create-bucket --bucket "$bucket_name" --create-bucket-configuration LocationConstraint=eu-west-1 > /dev/null

# Configure static website hosting
echo "Configuring static website hosting..."
aws s3 website "s3://$bucket_name/" --index-document index.html --error-document error.html > /dev/null

echo "Disabling 'Block all public access'..."
aws s3api put-public-access-block --bucket "$bucket_name" --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false" > /dev/null

echo "Adding the modified bucket policy..."
aws s3api put-bucket-policy --bucket "$bucket_name" --policy file://modified-policy.json > /dev/null

echo "Uploading index.html..."
aws s3 cp index.html "s3://$bucket_name/" > /dev/null

echo "Uploading error.html..."
aws s3 cp error.html "s3://$bucket_name/" > /dev/null

rm -rf modified-policy.json
echo "Deployment completed successfully."
