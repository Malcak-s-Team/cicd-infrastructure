#!/bin/sh 
outputFile="Your_PATH"
amzFile="AMAZON_FILE_PATH"
bucket="YOUR_BUCKET"

resource="/${bucket}/${amzFile}"
contentType="application/x-compressed-tar"
dateValue=`date -R`
stringToSign="GET\n\n${contentType}\n${dateValue}\n${resource}"

s3Key="YOUR_S3_KEY"
s3Secret="YOUR_S3SECRET"

signature=`echo -en ${stringToSign} | openssl sha1 -hmac ${s3Secret} -binary | base64`

curl  -H "Host: ${bucket}.s3.amazonaws.com" \
     -H "Date: ${dateValue}" \
     -H "Content-Type: ${contentType}" \
     -H "Authorization: AWS ${s3Key}:${signature}" \
     https://${bucket}.s3.amazonaws.com/${amzFile} -o $outputFile
