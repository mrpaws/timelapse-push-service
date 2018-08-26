#!/bin/sh

# fill in with your own details and mount to /srv/tlps/app/env-config.sh
# object storage
export S3_COMPAT_ENDPOINT='https://s3.amazonaws.com'
export S3_COMPAT_ACCESS_KEY='accesskey'
export S3_COMPAT_SECRET_KEY='secretkey'
export S3_COMPAT_API_VERSION='S3v4'
export S3_COMPAT_BUCKET_NAME='my-timelapse'

# timelapse app
export TRIGGER_FREQUENCY_CRON="*/5 * * * *"
export PRESERVE_LOCAL_FILES="yes"
export TIMELAPSE_PREFIX="tl"
export TIMEZONE="America/Los_Angeles"
export GPHOTO2_CLI_CONFIG_OPTIONS=""
