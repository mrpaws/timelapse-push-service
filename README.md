# timelapse-push-service
DSLR Timelapse automation with gphoto2 and object storage push to any s3-compatible provider (Built for use with Original Raspberry Pi


## Usage

using object storage only:
docker run \
  -v ${PWD}/docker/fs/srv/app/env-config.sh:/srv/app/tlps/app/env-config.sh \
  mrpaws/tlps:latest

using filesystem mount:
docker run \
  -v ${PWD}/docker/fs/srv/app/env-config.sh:/srv/app/tlps/app/env-config.sh \
  -v <ABSOLUTE_PATH_ON_HOST>/srv/app/tlps/data \
  mrpaws/tlps:latest


## Todo
- Add camera shoot script
- Add camera push script 
- Get s3proxy sidecar working to accommodate more backends
- Add volume support for local fs dumping
- Add option to config to toggle local remove on and off
- Add option to config for gphoto2 cli option mods



