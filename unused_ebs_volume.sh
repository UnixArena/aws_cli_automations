#!/bin/bash

SINCE=`date --date '-60 days' +%F 2>/dev/null || date -v '-60d' +%F`
echo $SINCE
#Get the available volumes excluding tagged "LastDetachTime"
#Should be created within last 60 days
while IFS=, read -r ACCOUNT REGION; do
aws ec2 describe-volumes --region $REGION --filters Name=status,Values=available --query "Volumes[*].{VolumeID:VolumeId,Region:AvailabilityZone,State:State,CreationTime:CreateTime}" --output text | tr -d [,{,\",\},\],\' | awk '$0 > "'"$SINCE"'"' >> EBS_60days_${ACCOUNT}_${REGION}

# Identify the volumes with specific tag
aws ec2 describe-volumes --region $REGION --filters Name=status,Values=available Name=tag-key,Values=LastDetachTime --query "Volumes[*].{VolumeID:VolumeId,Region:AvailabilityZone,State:State,CreationTime:CreateTime}" --output text | tr -d [,{,\",\},\],\' >> Tag_LastDetachTime_${ACCOUNT}_${REGION}

awk 'NR==FNR{a[$0];next}(!($0 in a)){print}' Tag_LastDetachTime_${ACCOUNT}_${REGION} EBS_60days_${ACCOUNT}_${REGION} |awk -v ncr=14 '{$1=substr($1,0,length($1)-ncr)}1' >> EBS_${ACCOUNT}_${REGION}

cat EBS_${ACCOUNT}_${REGION} | awk '{ print $1,substr( $2, 1, length($2)-1 ),$3,$4 }' > EBS_VOL_${ACCOUNT}_${REGION}
echo VolumeID,Region,CreationDate,DetachDate > EBS_Unsed_Volumes_${ACCOUNT}_${REGION}.csv
while IFS=' ' read -r DATE REGION STATUS VOLID; do
        DETTACH_TIME=$(aws cloudtrail lookup-events --lookup-attributes AttributeKey=ResourceName,AttributeValue=$VOLID --max-results 3 --region $REGION --query 'Events[?EventName == `DetachVolume`].CloudTrailEvent'  | sed 's/\\//g' | sed 's/"}"/"}/g' | sed 's/"{"/{"/g' | awk -F"," '{print $11}' | tr -d \",Z,eventTime: | cut -c 1-10)
echo $VOLID,$REGION,$DATE,$DETTACH_TIME >> EBS_Unsed_Volumes_${ACCOUNT}_${REGION}.csv
done < EBS_VOL_${ACCOUNT}_${REGION}

done < ACCOUNT_REGION

Create a file like below
lingesh@unixarena:~/EBS$ cat ACCOUNT_REGION
1234567,us-east-2
1234567,us-east-1
3456778,us-east-2
3456778,us-east-1
lingesh@unixarena:~/EBS$
