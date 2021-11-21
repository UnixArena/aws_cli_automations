#!/bin/bash

#Capture today's date
date=$(date '+%Y-%m-%d')

#Define destination bucket name
DEST_BUCKET=test2ualin

#Define the number of days
SINCE=`date --date '-9 weeks +2 days' +%F 2>/dev/null || date -v '-9w' -v '+2d' +%F`

while read -r line; do
        COUNT=$(aws s3api list-objects-v2 --bucket "$line" --query 'Contents[?LastModified < `'"$SINCE"'`].Key'| wc -l)
        if [ "${COUNT}" -gt "1" ]; then
                aws s3 cp s3://$line/ s3://$DEST_BUCKET/${line}_$date/ --recursive
                echo $line >> s3bucketlist_updated_$date.txt
        fi
done < "s_list.txt"
#Store the source source bucket list in s3_list.txt
