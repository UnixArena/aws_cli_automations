#/fmac/users/iaaspuser/bin/awscli.bash AWS "$ACCOUNT"cloudadminrolebyadfs
date=$(date '+%Y-%m-%d')
DEST_BUCKET=awss3testone

YR=`date --date '-1 year' +%F 2>/dev/null || date -v '-1y' -v  +%F`
SINCE=`date --date '-6 months +2 days' +%F 2>/dev/null || date -v '-6m' -v '+2d' +%F`

#Determine destination s3 bucket is writable
touch check_write_access
aws s3 cp check_write_access s3://$DEST_BUCKET --profile itl01cloudadminrolebyadfs > /dev/null || write_api_exit=$?
if [[ ${write_api_exit} -eq 0 ]]; then
   echo "User has access to the destination bucket"

  #Identify the buckets which are more than one year old
  #aws s3 ls |grep -v $DEST_BUCKET | awk '$0 < "'"$YR"'"' | awk ' { print $3 } '  > s3_buck.list

while read -r bucketname; do
   LASTM=`aws s3 ls $bucketname  --recursive --profile itl01cloudadminrolebyadfs | sort -r |awk ' { print $1 } '  | head -1`
   if [[ -z "$LASTM" ]]; then
        echo "Bucket $bucketname is empty" >> s3bucketlist_updated_$date.txt
   else
  
   # Determine source s3 buckets are readable
   read_api_exit=0
   GETFILE=`aws s3api list-objects-v2 --bucket $bucketname --profile itl01cloudadminrolebyadfs | grep Key | awk -F':' ' { print $2 } ' | head -1 | tr -d ',' `
   GETACL="aws s3api get-object-acl --bucket $bucketname  --key $GETFILE --profile itl01cloudadminrolebyadfs >/dev/null"
   eval "$GETACL" || read_api_file=$?

    if [[ $read_api_exit -eq 0 ]]; then
           if  [[ "$LASTM" < "$SINCE" ]]; then
             copy_api_exit=0
             aws s3 cp s3://$bucketname/ s3://$DEST_BUCKET/${bucketname}_$date/ --recursive --profile itl01cloudadminrolebyadfs || copy_api_exit=$?
                  if [[ ${copy_api_exit} -eq 0 ]]; then
                       echo "sucessfully copied $bucketname" >> s3bucketlist_updated_$date.txt
                  else
                       echo "Unable to copy the bucket: $bucketname to destination bucket" >> s3bucketlist_updated_$date.txt
                  fi
          else
                echo "Bucket $bucketname has object uploaded within last 6 months"  >> s3bucketlist_updated_$date.txt
           fi
       else
         #updated the access denied bucket list
         echo "Access denied bucket $bucketname" >> s3bucketlist_updated_$date.txt
    fi
  fi
done < "s3_buck.list"

else
  echo "user do not have access to the destination bucket"
fi
