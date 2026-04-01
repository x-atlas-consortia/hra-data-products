#!/bin/bash
source constants.sh
shopt -s extglob
set -ev

CLEAN="--delete"

if [ "${CDN_S3_BUCKET}" != "" ]; then
  aws s3 sync --exclude "${OUTPUT_DIR}/.git/*" $CLEAN ${OUTPUT_DIR}/ ${CDN_S3_BUCKET}

  if [ "${CDN_DISTRIBUTION_ID}" != "" ]; then
    aws cloudfront create-invalidation --distribution-id ${CDN_DISTRIBUTION_ID} --paths "/data-products/*" > /dev/null
  fi
fi
