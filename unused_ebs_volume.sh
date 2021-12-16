#!/bin/bash

SINCE=`date --date '-60 days' +%F 2>/dev/null || date -v '-60d' +%F`
echo $SINCE
#Get the available volumes excluding tagged "LastDetachTime"
#Should be created within last 60 days
aws ec2 describe-volumes  --filters Name=status,Values=available --query "Volumes[*].{VolumeID:VolumeId,Region:AvailabilityZone,State:State,CreationTime:CreateTime}" --output text | tr -d [,{,\",\},\],\' | awk '$0 > "'"$SINCE"'"' > EBS_Volume_List_Last_60days

# Identify the volumes with specific tag
aws ec2 describe-volumes --filters Name=status,Values=available Name=tag-key,Values=LastDetachTime --query "Volumes[*].{VolumeID:VolumeId,Region:AvailabilityZone,State:State,CreationTime:CreateTime}" --output text | tr -d [,{,\",\},\],\' > Tag_Volumes_LastDetachTime

awk 'NR==FNR{a[$0];next}(!($0 in a)){print}' Tag_Volumes_LastDetachTime EBS_Volume_List_Last_60days |awk -v ncr=14 '{$1=substr($1,0,length($1)-ncr)}1' > EBS_Unsed_Volume_without_LastDetachTime

cat EBS_Unsed_Volume_without_LastDetachTime | awk '{ print $1,substr( $2, 1, length($2)-1 ),$3,$4 }' > EBS_Unsed_Volume_without_LastDetachTime_Region
echo VolumeID,Region,CreationDate,DetachDate > EBS_Unsed_Volumes.csv
while IFS=' ' read -r DATE REGION STATUS VOLID; do
        DETTACH_TIME=$(aws cloudtrail lookup-events --lookup-attributes AttributeKey=ResourceName,AttributeValue=$VOLID --max-results 3 --region $REGION --query 'Events[?EventName == `DetachVolume`].CloudTrailEvent'  | sed 's/\\//g' | sed 's/"}"/"}/g' | sed 's/"{"/{"/g' | awk -F"," '{print $11}' | tr -d \",Z,eventTime: | cut -c 1-10)
echo $VOLID,$REGION,$DATE,$DETTACH_TIME >> EBS_Unsed_Volumes.csv
done < EBS_Unsed_Volume_without_LastDetachTime_Region
