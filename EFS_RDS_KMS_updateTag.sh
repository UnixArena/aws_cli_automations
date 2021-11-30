#!/bin/bash

while IFS=, read -r ARN KEY VALUE; do
        RTYPE=`echo $ARN | cut -d: -f 3`
        RTYPE_EFS=`echo $ARN | cut -c 1-3`
        if [[ "$RTYPE" = kms ]]; then
          aws kms tag-resource --key-id $ARN  --tags TagKey=$KEY,TagValue=$VALUE
          if [[ "$?" > 0 ]]; then
            echo "Unable to update tag for KMS resource - $ARN" >> RDS_EFS_KMS.log
          fi

        elif [[ "$RTYPE"  = rds ]]; then
            aws rds add-tags-to-resource --resource-name $ARN --tags "[{\"Key\": \"$KEY\",\"Value\": \"$VALUE\"}]"
          if [[ "$?" > 0 ]]; then
            echo "Unable to update tag for RDS resource - $ARN" >> RDS_EFS_KMS.log
          fi

        elif [[ "$RTYPE_EFS" = fs- ]]; then
            aws efs tag-resource --resource-id $ARN --tags Key=$KEY,Value=$VALUE
          if [[ "$?" > 0 ]]; then
            echo "Unable to update tag for EFS resource - $ARN" >> RDS_EFS_KMS.log
          fi

        else
            echo "Given resource list is not KMS, RDS & EFS resource: $ARN" >> RDS_EFS_KMS.log
        fi

        done < RDS_EFS_KMS_list
