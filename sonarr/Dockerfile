ARG LSIO_IMAGE_VERSION=develop-version-4.0.0.740
FROM alpine:3.18.3 AS buildstage

ARG RCLONE_VERSION=${RCLONE_VERSION:-v1.65.0}
ARG RCLONE_URL=https://downloads.rclone.org/${RCLONE_VERSION}/rclone-${RCLONE_VERSION}-linux-amd64.zip
ARG RCLONE_FILENAME=rclone-${RCLONE_VERSION}-linux-amd64
ARG RCLONE_EXT=.zip

RUN apk --update add wget unzip ffmpeg && \
  mkdir -p /workdir/ && \
  mkdir -p /root-layer/usr/local/bin/ && \
  wget -O /workdir/$RCLONE_FILENAME$RCLONE_EXT "$RCLONE_URL" && \
  unzip /workdir/$RCLONE_FILENAME$RCLONE_EXT -d /workdir && \
  chmod a+x "/workdir/$RCLONE_FILENAME/rclone" && \
  mv /workdir/$RCLONE_FILENAME/rclone /root-layer/usr/local/bin/rclone && \
  mv /usr/bin/ffprobe /root-layer/usr/local/bin/ffprobe

COPY docker-mods/pm-base-tools/root/ /root-layer/

## Start LSIO Image
FROM linuxserver/sonarr:$LSIO_IMAGE_VERSION

COPY --from=buildstage /root-layer/ /
COPY docker-mods/rclone-rotate-service-account/root/ /
