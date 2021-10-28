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

#tag="TagSet=[{Key=$tag_name,Value=$tag_new_value}]"

#Proceed to update the new tag value ?
while true; do
            read -p "Do you wish to update the new tag value for key - $tag_name ?" yn
                case $yn in
                                [Yy]* ) for i in `cat $s3_bucket_list`;do 
                                        data=$(aws s3api get-bucket-tagging --bucket $i | jq .TagSet | sed "s/$Current_Tag_Value/$New_Tag_Value/g" | sed "s/:/=/g"| sed "s/\"//g");
                                        aws s3api put-bucket-tagging --bucket $i --tagging "TagSet=$data";
                                        aws s3api get-bucket-tagging --bucket $i; # should print the merged tags
                                        done; break;;
                                [Nn]* ) exit;;
             * ) echo "Please answer yes or no.";;
                                    esac
            done
