ARG LSIO_IMAGE_VERSION=jammy-version-85b73e03
FROM alpine:3.15.2 AS buildstage

ARG RCLONE_VERSION=${RCLONE_VERSION:-v1.58.1}
ARG RCLONE_URL=https://downloads.rclone.org/${RCLONE_VERSION}/rclone-${RCLONE_VERSION}-linux-amd64.zip
ARG RCLONE_FILENAME=rclone-${RCLONE_VERSION}-linux-amd64
ARG RCLONE_EXT=.zip

RUN apk --update add wget unzip && \
  mkdir -p /workdir/ && \
  mkdir -p /root-layer/usr/local/bin/ && \
  wget -O /workdir/$RCLONE_FILENAME$RCLONE_EXT "$RCLONE_URL" && \
  unzip /workdir/$RCLONE_FILENAME$RCLONE_EXT -d /workdir && \
  chmod a+x "/workdir/$RCLONE_FILENAME/rclone" && \
  mv /workdir/$RCLONE_FILENAME/rclone /root-layer/usr/local/bin/rclone

COPY docker-mods/pm-base-tools/root/ /root-layer/

## Start LSIO Image
FROM lsiobase/ubuntu:$LSIO_IMAGE_VERSION

COPY --from=buildstage /root-layer/ /
COPY docker-mods/rclone-rotate-service-account/root/ /
COPY docker-mods/pm-plex-base/root/ /
COPY docker-mods/plex-unicorn-transcoder/root/ /

HEALTHCHECK --interval=10s --timeout=8s CMD /healthcheck.sh || exit 1

