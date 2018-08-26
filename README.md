
# timelapse-push-service
DSLR Timelapse automation with full gphoto2 functionality and object storage push to any s3-compatible provider (Built for use with Original Raspberry Pi) with most cameras that support some level of PTP/IP 

## Details
This tool is an intervalometer for any gphoto2-supported camera that pushes results to object storage and/or a mounted filesystem.  It can take all of gphoto2's CLI options and works with very many cameras.  I made this to take a multi-month time lapse of a mountain and to make use of a dusty, old, original raspberry pi.  

I don't have time to maintain this actively but is functional on latest docker-ce on rasbian stretch lite on RPi 1.  It probably works with any linux docker host (see TODO). 

Privileged mode is required to access the attached camera.

#### Notes on implementation

- Because different devices can be specified through gphoto2 command line options, it is possible to deploy many containers to a single device to operate many cameras, each with it's own unique parameters, push endpoints, etc.

- If you deploy this application onto more recent pi models, then a kubernetes cluster of controlled cameras could be achieved.

- This was mostly a self-service project to get something done quickly for myself, and I don't intend to spend time on feature requests, but if you have an idea for better design or a feature please open an issue because good ideas have a tendency to encourage me to action. :)

## Usage

**First edit the values** in env-config.sh, or just create your own using the below template. You can find a crontab reference below.  Here is the example provided:

    #/bin/bash
    
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


### Then run the container
If you build it yourself be sure to change the image reference.  The below will pull from Docker Hub

#### Object storage only:

    docker run --privileged \
      -v ${PWD}/env-config.sh:/srv/app/tlps/app/env-config.sh \
      mrpaws/tlps:latest

#### With Filesystem mount:

    docker run --privileged \
      -v ${PWD}/env-config.sh:/srv/app/tlps/app/env-config.sh \
      -v <ABSOLUTE_PATH_ON_HOST>/srv/app/tlps/data \
      mrpaws/tlps:latest


## Crontab Help

    # ┌───────────── minute (0 - 59)
    # │ ┌───────────── hour (0 - 23)
    # │ │ ┌───────────── day of month (1 - 31)
    # │ │ │ ┌───────────── month (1 - 12)
    # │ │ │ │ ┌───────────── day of week (0 - 6) (Sunday to Saturday;
    # │ │ │ │ │                                   7 is also Sunday on some systems)
    # │ │ │ │ │
    # │ │ │ │ │
    # * * * * * command to execute

#### Example
The definition below will fire every 10 minutes from 5am to 9pm:

    TRIGGER_FREQUENCY_CRON="*/10 5-21 * * *"

## Gphoto2 Help
Supported Cameras: http://gphoto.org/proj/libgphoto2/support.php
Camera Configuration Help: http://www.gphoto.org/doc/remote/

#### Example Set Config
The configuration parameters below will take 2 shots every 30 seconds when the cron job to start gphoto2 fires, and the camera beep will be disabled.  This is one way to improve granularity of control over the camera with the app. 

    GPHOTO2_CLI_CONFIG_OPTIONS="-F 2 -I 30 --set-config beep =0"

## Todo
- Get s3proxy sidecar working to accommodate more backends
- Enhance security around credentials file
- Make the push routine
- Better modularize
- Rebuild repo with a simple install script for non-docker implementations
