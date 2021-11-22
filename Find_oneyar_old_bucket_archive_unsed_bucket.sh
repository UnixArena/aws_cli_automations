#!/bin/bash

date=$(date '+%Y-%m-%d')
DEST_BUCKET=test2ualin

YR=`date --date '-1 year' +%F 2>/dev/null || date -v '-1y' -v  +%F`
SINCE=`date --date '-6 months +2 days' +%F 2>/dev/null || date -v '-6m' -v '+2d' +%F`
aws s3 ls |grep -v $DEST_BUCKET | awk '$0 < "'"$YR"'"' | awk ' { print $3 } '  > s3_buck.list

while read -r line; do
        COUNT=$(aws s3api list-objects-v2 --bucket "$line" --query 'Contents[?LastModified > `'"$SINCE"'`].Key'| wc -l)

        #echo $COUNT
        if [ "${COUNT}" -gt "1" ]; then
                aws s3 cp s3://$line/ s3://$DEST_BUCKET/${line}_$date/ --recursive
                echo $line >> s3bucketlist_updated_$date.txt
        fi
done < "s3_buck.list"
