# !/bin/bash
if [[ -z "${AWS_ACCESS_KEY_ID}" ]] || [[ -z "${AWS_SECRET_ACCESS_KEY}" ]]; then
  echo "AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY are required variables, export it before running the script"
  exit 1
fi

if [[ -z "${S3_BUCKET}" ]]; then
  echo "S3_BUCKET target bucket variable should be exported before running the script"
  exit 1
fi

if [[ -z "${S3_BUCKET_PATH}" ]]; then
  S3_BUCKET_PATH="/"
fi

path=$1

aws s3 cp $path "$S3_BUCKET$S3_BUCKET_PATH"
