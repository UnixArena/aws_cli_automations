#!/bin/bash

date=$(date '+%Y-%m-%d')
DEST_BUCKET=test2ualin

YR=`date --date '-1 year' +%F 2>/dev/null || date -v '-1y' -v  +%F`
SINCE=`date --date '-6 months +2 days' +%F 2>/dev/null || date -v '-6m' -v '+2d' +%F`

#Determine destination s3 bucket is writable
touch check_write_access
aws s3 cp check_write_access s3://$DEST_BUCKET --sse AES256 > /dev/null || write_api_exit=$?
if [[ ${write_api_exit} -eq 0 ]]; then
   echo "User has access to the destination bucket"

   #Identify the buckets which are less than one year old
   aws s3 ls |grep -v $DEST_BUCKET | awk '$0 < "'"$YR"'"' | awk ' { print $3 } '  > s3_buck.list

   while read -r line; do
   # Determine source s3 buckets are readable
   read_api_exit=0
   aws s3api list-objects-v2 --bucket $line > /dev/null || read_api_exit=$?
    if [[ ${read_api_exit} -eq 0 ]]; then
        LASTM=`aws s3 ls "$line" --recursive | sort -r |awk ' { print $1 } '  | head -1`
        if [ -z "$LASTM" && "$LASTM" < "$SINCE" ]; then
              aws s3 cp s3://$line/ s3://$DEST_BUCKET/${line}_$date/ --recursive --sse AES256 || copy_api_exit=$?
                if [[ ${copy_api_exit} -eq 0 ]]; then
                  echo $line >> s3bucketlist_updated_$date.txt
                else
                  echo "Unable to copy the bucket: $line to destination bucket" >> s3bucketlist_updated_$date.txt
                fi
           else
                echo "Bucket $line has object uploaded within last 60 days or empty"  >> s3bucketlist_updated_$date.txt
        fi
     else
    #updated the access denied bucket list
        echo "Access denied Bucket $line" >> s3bucketlist_updated_$date.txt
    fi
done < "s3_buck.list"

else
  echo "user do not have access to the destination bucket"
fi
