   while read -r line; do
   # Determine source s3 buckets are readable
   read_api_exit=0
   for  file_name in `aws s3api list-objects-v2 --bucket $line | grep Key | awk ' { print $2 } ' | head -1 | tr -d \",\,`; do aws s3api get-object-acl --bucket $line --key $file_name >/dev/null; done  || read_api_exit=$? 
   #########aws s3api list-objects-v2 --bucket $line > /dev/null || read_api_exit=$?
    if [[ $read_api_exit -eq 0 ]]; then
        LASTM=`aws s3 ls "$line" --recursive | sort -r |awk ' { print $1 } '  | head -1`
        if [[ -n "$LASTM" ]] && [[ "$LASTM" < "$SINCE" ]]; then
              copy_api_exit=0
