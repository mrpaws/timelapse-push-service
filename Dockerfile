FROM alpine:latest

MAINTAINER mrpaws <mrpaws@github>
LABEL description="timelapse-push-service multiarch container components"
LABEL info="https://github.com/mrpaws/timelapse-push-service"
LABEL dockerhub="mrpaws/timelapse-push-service"


# install s3 client reqs (mc), timezone configurations and gphoto2
# TODO: cli install multiarch, or build alpine packages :)
RUN \
    apk update && \
    apk add --no-cache gphoto2 tzdata bash ca-certificates && \
    apk add --no-cache --virtual .build-deps curl && \
    curl https://dl.minio.io/client/mc/release/linux-arm/mc > /usr/bin/mc && \
    chmod +x /usr/bin/mc && \
    apk del .build-deps

ENV DATADIR=/srv/tlps/data
ENV APPDIR=/srv/tlps/app

# app config file mount
VOLUME ${APPDIR}/env-config.sh

# optional volume mount
VOLUME $DATADIR

ADD  ./docker/fs/srv/tlps/app/entry.sh $APPDIR/entry.sh
ADD  ./docker/fs/srv/tlps/app/shoot.sh $APPDIR/shoot.sh

ENTRYPOINT "/bin/bash"
