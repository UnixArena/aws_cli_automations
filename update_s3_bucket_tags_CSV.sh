#!/bin/bash

while IFS=, read -r BUCKETNAME OLDTAG NEWTAG ACCOUNT; do
            export AWS_PROFILE="$ACCOUNT"clouddeveloperrolebyadfs
            aws s3api get-bucket-tagging --bucket $BUCKETNAME > xyz.json
            echo "updating tag for $BUCKETNAME"
            sed -i 's/'"$OLDTAG"'/'"$NEWTAG"'/g' xyz.json
            aws s3api put-bucket-tagging --bucket $BUCKETNAME --tagging file://xyz.json
            echo "List of tags for $BUCKETNAME after update"
            aws s3api get-bucket-tagging --bucket $BUCKETNAME
                        done < s3_list
                        
                        
Sample CSV file.
test1ualin,OLDTAG,NEW_TAG,ACCOUNTID
test2ualin,OLDTAG2,NEW2_TAG,ACCOUNTID
