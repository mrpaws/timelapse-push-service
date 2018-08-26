#!/bin/bash
# take the picture, save, push and maybe delete

shopt -s extglob

function configure_environment {
  . /srv/tlps/app/env-config.sh || echo "WARN: No env-config.sh detected"
  # set sane defaults in case omitted from config
  GPHOTO2_CLI_CONFIG_OPTIONS=${GPHOTO_CLI_CONFIG_OPTIONS:-""}
  TIMELAPSE_PREFIX=${TIMELAPSE_PREFIX:-""}
  DATADIR=${DATADIR:-"/srv/tlps/data"}
  PRESERVE_LOCAL_FILES=${PRESERVE_LOCAL_FILES:-"yes"}
  PRESERVE_LOCAL_FILES=$(echo ${PRESERVE_LOCAL_FILES} | tr [A-Z] [a-z]) 
  if [[ "${PRESERVE_LOCAL_FILES}" == !(yes|no) ]]; then
    echo "ERROR: Invalid PRESERVE_LOCAL_FILES var val (${PRESERVE_LOCAL_FILES})"
  fi

}


# main Main MAIN

echo "$(date) : Running timelapse-push-service from cron spec..."

configure_environment 

result=$(/usr/bin/gphoto2 \
  --capture-image-and-download \
  --filename "${DATADIR}/${TIMELAPSE_PREFIX}%Y%m%d%H%M%S.%C" \
  ${GPHOTO2_CLI_CONFIG_OPTIONS} | \
  grep "Saving file as" | \
  awk '{print $NF}'; 
  echo ${PIPESTATUS[@]})

output=$(head -n -1 <<< "$result")
status=($(tail -n 1 <<< "$result"))

for i in ${status[@]}
do 
  if [ ${i} -gt 0 ]; then
    echo "ERROR: Problem capturing photograph."
    echo "$output"
    exit 1
  fi
done


for imagepath in ${output}
do
  mc cp ${imagepath} timelapse/${S3_COMPAT_BUCKET_NAME}
  if [ $? -eq 0 ]; then
    echo "INFO: Pushed ${imagepath} to (${S3_COMPAT_ENDPOINT}) bucket (${S3_COMPAT_BUCKET_NAME})"
  else
    echo "ERROR: Failed to push ${imagepath} to (${S3_COMPAT_ENDPOINT}) bucket (${S3_COMPAT_BUCKET_NAME})"
  fi
  if [ "${PRESERVE_LOCAL_FILES}" == "no" ]; then
    echo "INFO: Removing local file."
    rm ${imagepath}
  else 
    echo "INFO: Local file saved at ${imagepath}".
  fi
done


exit 0
