#!/bin/bash

#Capture today's date
date=$(date '+%Y-%m-%d')

#Define destiation bucket list 
DEST_BUCKET=test2ualin

SINCE=`date --date '-9 weeks +2 days' +%F 2>/dev/null || date -v '-9w' -v '+2d' +%F`

#Fetch S3 bucket using aws cli and store it in s3_buck.list
aws s3api list-buckets --query 'Buckets[].[Name]' --output text |grep -v $DEST_BUCKET > s3_buck.list

while read -r line; do
        COUNT=$(aws s3api list-objects-v2 --bucket "$line" --query 'Contents[?LastModified > `'"$SINCE"'`].Key'| wc -l)
        if [ "${COUNT}" -gt "1" ]; then
                aws s3 cp s3://$line/ s3://$DEST_BUCKET/${line}_$date/ --recursive
                echo $line >> s3bucketlist_updated_$date.txt
        fi
done < "s3_buck.list"
