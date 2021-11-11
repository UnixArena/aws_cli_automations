#!/bin/bash

while IFS=, read -r ARN KEY VALUE; do
            ET=`aws resourcegroupstaggingapi get-resources --resource-arn-list $ARN |grep '"Key": "CostCenter"' -A1  | tr -d '\n'`
            if [[ -z $ET ]]; then
            aws resourcegroupstaggingapi tag-resources --resource-arn-list $ARN --tags Environment=$KEY,CostCenter=$VALUE
            echo "List of tags for $ARN after update"
            aws resourcegroupstaggingapi get-resources --resource-arn-list $ARN 
            else
            echo " $ARN has existing CostCenter tag - $ET" >> Tag_Update.log
            fi
        done < s3_list
