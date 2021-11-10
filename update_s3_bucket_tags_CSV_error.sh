#!/bin/bash
cat /dev/null > Tagupdate.log
while IFS=, read -r BUCKETNAME KEY OLDTAG NEWTAG; do
            aws s3api get-bucket-tagging --bucket $BUCKETNAME > xyz.json 
            if [[ $? -ne 0 ]]; then
                    echo "unable to fetch the tags for $BUCKETNAME" >> Tagupdate.log;
            else 
                #Reverse the file content for Key value update
                tac xyz.json  > reverse_xyz.json
                    echo "updating tag for $BUCKETNAME"
                    sed -i '/'"$KEY"'/ {N;s/'"$OLDTAG"'/'"$NEWTAG"'/}' reverse_xyz.json 
                tac reverse_xyz.json > xyz.json
                aws s3api put-bucket-tagging --bucket $BUCKETNAME --tagging file://xyz.json
                if [[ $? -ne 0 ]]; then
                        echo "unable to update the tags for $BUCKETNAME" >> Tagupdate.log;
           else 
                echo "List of tags for $BUCKETNAME after update"
               aws s3api get-bucket-tagging --bucket $BUCKETNAME
                fi
            fi
done < s3_list
