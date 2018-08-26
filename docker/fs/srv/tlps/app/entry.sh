#!/bin/bash
# entry.sh - timelapse-push-service entrypoint script

set -ex

function read_environment_config {
  . /srv/tlps/app/env-config.sh || echo "WARN: No env-config.sh detected"
}

function configure_timezone {
  echo "INFO: Configuring Timezone"
  TIMEZONE=${TIMEZONE:-"America/Los_Angeles"}
  cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime || \
    echo "WARN: Unable to copy timezone file for timezone (${TIMEZONE}) to /etc/localtime." 
  echo "${TIMEZONE}" > /etc/timezone || \
    echo "WARN: Unable to update timezone to (${TIMEZONE})."
  echo "INFO: System date/time is now $(date)"
}

function check_environment {
  echo "INFO: Checking environment variables..."
  error_cnt=0
  for y in 'S3_COMPAT_ENDPOINT' \
    'S3_COMPAT_ACCESS_KEY'      \
    'S3_COMPAT_SECRET_KEY'      \
    'S3_COMPAT_API_VERSION'     \
    'S3_COMPAT_BUCKET_NAME'     \
    'TIMELAPSE_PREFIX'          \
    'TRIGGER_FREQUENCY_CRON'    \
    'PRESERVE_LOCAL_FILES'      \
    'TIMEZONE'                  
    do 
      if [ -z "${!y+x}" -o -z "${!y}" ]; then 
        echo "ERROR: ${y} is not set or zero length.";
        let error_cnt++
      else 
        echo "GOOD: Environment variable ${y} detected."; 
      fi; 
  done

  if [ ${error_cnt} -eq 0 ]; then
    echo "GOOD: Looks like all neccessary variables are set."
    return 0
  else
    echo "*********************************************************************"
    echo "ERROR: Critical errors detected in environment variable reading. Is env-config.sh mounted?"
    echo "UNLESS A VOLUME IS MOUNTED TO ${DATADIR} YOUR IMAGES WILL NOT PERIST."
    echo "********************************************************************"
    return 1
  fi
}

function install_crontab {
  TRIGGER_FREQUENCY_CRON=${TRIGGER_FREQUENCY_CRON:-"*/5 * * * *"}
  echo "Installing crontab... (${TRIGGER_FREQUENCY_CRON})"
  echo "${TRIGGER_FREQUENCY_CRON} /srv/tlps/app/tlps.sh" | crontab -
}

function configure_mc {
  echo "INFO: Configuring and testing object storage..."
  mc config host add timelapse \
    ${S3_COMPAT_ENDPOINT} \
    ${S3_COMPAT_ACCESS_KEY} \
    ${S3_COMPAT_SECRET_KEY} \
    ${S3_COMPAT_API_VERSION}
  if [ $? -eq 0 ]; then
    echo "GOOD: mc configuration success."
  else
    echo "ERROR: mc configuration failure."
    exit 3
  fi

  # list remote bucket
  mc ls timelapse/${S3_COMPAT_BUCKET_NAME}
  if [ $? -eq 0 ]; then
    echo "GOOD: mc remote bucket read test success."
  else
    echo "ERROR: mc remote bucket read test failure."
    exit 4
  fi

  testfile="${DATADIR}/${TIMELAPSE_PREFIX}pushtest.txt"

  # create file in datadir (test in case mounted)
  touch  ${testfile}
  if [ $? -eq 0 ]; then
    echo "GOOD: local file write success (${DATADIR})."
  else
    echo "ERROR: local file write failure (${DATADIR})."
    exit 5
  fi
  
  # copy file from datadir to object storage
  mc cp ${testfile} timelapse/${S3_COMPAT_BUCKET_NAME}
    if [ $? -eq 0 ]; then
    echo "GOOD: Object storage write success (${S3_COMPAT_ENDPOINT})."
  else
    echo "ERROR: Object storage write failure (${S3_COMPAT_ENDPOINT})."
    exit 6
  fi

  rm ${testfile}
    if [ $? -eq 0 ]; then
    echo "GOOD: local file removal success (${DATADIR})."
  else
    echo "ERROR: local file removal failure (${DATADIR})."
    exit 6
  fi

  echo "GOOD: Local and object storage permissions and connectivity seem adequate."
  return 0
}

# main Main MAIN

DATADIR="/srv/tlps/data"
APPDIR="/srv/tlps/app"

read_environment_config
configure_timezone 
check_environment && configure_mc
install_crontab

crond -f -L -
