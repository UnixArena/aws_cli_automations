#!/bin/bash

#Enter the S3 Bucket List 
echo "Enter the file path with name(S3 Bucket List):" 
read s3_bucket_list 

#Enter the current tag value 
echo "Enter the current tag value:" 
read Current_Tag_Value 

#Enter the new tag value to update.
echo "Enter the new tag value:"
read New_Tag_Value 

while IFS= read -r BUCKETNAME; do
            aws s3api get-bucket-tagging --bucket $BUCKETNAME > xyz.json
                echo "updating tag for $BUCKETNAME"
                    sed -i 's/'"$Current_Tag_Value"'/'"$New_Tag_Value"'/g' xyz.json
                        aws s3api put-bucket-tagging --bucket $BUCKETNAME --tagging file://xyz.json
                            echo "List of tags for $BUCKETNAME after update"
                                aws s3api get-bucket-tagging --bucket $BUCKETNAME
                        done < $s3_bucket_list
