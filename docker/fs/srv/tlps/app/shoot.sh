#!/bin/bash
# take the picture

function read_environment_config {
  . /srv/tlps/app/env-config.sh || echo "WARN: No env-config.sh detected"
}


# main Main MAIN

read_environment_config 

# set sane defaults in case omitted from config
GPHOTO2_CLI_CONFIG_OPTIONS=${GPHOTO_CLI_CONFIG_OPTIONS:-""}
TIMELAPSE_PREFIX=${TIMELAPSE_PREFIX:-""}
DATADIR=${DATADIR:-"/srv/tlps/data"}

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
  if [ $i -gt 0 ]; then
    echo "ERROR: Problem capturing photograph."
    echo "$output"
    exit 1
  fi
done

echo "$output"

exit 0
