#!/bin/bash

while IFS=, read -r ARN KEY VALUE; do
            ET=`aws resourcegroupstaggingapi get-resources --resource-arn-list $ARN --query 'ResourceTagMappingList[].Tags[?Key==\`CostCenter\`].Value[]' --output text` 
            echo $ARN, $KEY, $ET >> Old_Tag_Update.csv
            if [[ -z "$ET" ]]; then
            #aws resourcegroupstaggingapi tag-resources --resource-arn-list $ARN --tags Environment=$KEY,CostCenter=$VALUE
            echo "List of tags for $ARN after update"
            aws resourcegroupstaggingapi get-resources --resource-arn-list $ARN 
            else
            echo " $ARN has existing CostCenter tag - $ET" >> Tag_Update.log
            fi
        done < s3_list
