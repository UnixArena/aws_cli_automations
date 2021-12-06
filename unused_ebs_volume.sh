#!/bin/bash

SINCE=`date --date '-60 days' +%F 2>/dev/null || date -v '-60d' +%F`
echo $SINCE

#Should be created within last 60 days
aws ec2 describe-volumes  --filters Name=status,Values=available --query "Volumes[*].{VolumeID:VolumeId,Region:AvailabilityZone,State:State,CreationTime:CreateTime}" --output text | tr -d [,{,\",\},\],\' | awk '$0 > "'"$SINCE"'"' > EBS_Volume_List_Last_60days

# Identify the volumes with specific tag
aws ec2 describe-volumes --filters Name=status,Values=available Name=tag-key,Values=LastDetachTime --query "Volumes[*].{VolumeID:VolumeId,Region:AvailabilityZone,State:State,CreationTime:CreateTime}" --output text | tr -d [,{,\",\},\],\' > Tag_Volumes_LastDetachTime

awk 'NR==FNR{a[$0];next}(!($0 in a)){print}' Tag_Volumes_LastDetachTime EBS_Volume_List_Last_60days > EBS_Unsed_Volume_without_LastDetachTime
