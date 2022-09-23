ARG LSIO_IMAGE_VERSION=develop-4.2.0.6438-ls66
FROM alpine:3.15.4 AS buildstage

ARG RCLONE_VERSION=${RCLONE_VERSION:-v1.59.1}
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

## Install Fluentbit into container
FROM fluent/fluent-bit AS fluentbit

## Start LSIO Image
FROM linuxserver/radarr:$LSIO_IMAGE_VERSION

COPY --from=buildstage /root-layer/ /
COPY --from=fluentbit /fluent-bit /fluent-bit
# Copy certificates
COPY --from=fluentbit /usr/share/ca-certificates/  /usr/share/ca-certificates/
COPY --from=fluentbit /etc/ssl/ /etc/ssl/

# SSL stuff
COPY --from=fluentbit /usr/lib/x86_64-linux-gnu/*sasl* /usr/lib/x86_64-linux-gnu/
COPY --from=fluentbit /usr/lib/x86_64-linux-gnu/libz* /usr/lib/x86_64-linux-gnu/
COPY --from=fluentbit /lib/x86_64-linux-gnu/libz* /lib/x86_64-linux-gnu/
COPY --from=fluentbit /usr/lib/x86_64-linux-gnu/libssl.so* /usr/lib/x86_64-linux-gnu/
COPY --from=fluentbit /usr/lib/x86_64-linux-gnu/libcrypto.so* /usr/lib/x86_64-linux-gnu/

# These below are all needed for systemd
COPY --from=fluentbit /lib/x86_64-linux-gnu/libsystemd* /lib/x86_64-linux-gnu/
COPY --from=fluentbit /lib/x86_64-linux-gnu/libselinux.so* /lib/x86_64-linux-gnu/
COPY --from=fluentbit /lib/x86_64-linux-gnu/liblzma.so* /lib/x86_64-linux-gnu/
COPY --from=fluentbit /usr/lib/x86_64-linux-gnu/liblz4.so* /usr/lib/x86_64-linux-gnu/
COPY --from=fluentbit /lib/x86_64-linux-gnu/libgcrypt.so* /lib/x86_64-linux-gnu/
COPY --from=fluentbit /lib/x86_64-linux-gnu/libpcre.so* /lib/x86_64-linux-gnu/
COPY --from=fluentbit /lib/x86_64-linux-gnu/libgpg-error.so* /lib/x86_64-linux-gnu/
COPY --from=fluentbit /usr/lib/x86_64-linux-gnu/libpq.so* /usr/lib/x86_64-linux-gnu/
COPY --from=fluentbit /usr/lib/x86_64-linux-gnu/libgssapi* /usr/lib/x86_64-linux-gnu/
COPY --from=fluentbit /usr/lib/x86_64-linux-gnu/libldap* /usr/lib/x86_64-linux-gnu/
COPY --from=fluentbit /usr/lib/x86_64-linux-gnu/libkrb* /usr/lib/x86_64-linux-gnu/
COPY --from=fluentbit /usr/lib/x86_64-linux-gnu/libk5crypto* /usr/lib/x86_64-linux-gnu/
COPY --from=fluentbit /usr/lib/x86_64-linux-gnu/liblber* /usr/lib/x86_64-linux-gnu/
COPY --from=fluentbit /usr/lib/x86_64-linux-gnu/libgnutls* /usr/lib/x86_64-linux-gnu/
COPY --from=fluentbit /usr/lib/x86_64-linux-gnu/libp11-kit* /usr/lib/x86_64-linux-gnu/
COPY --from=fluentbit /usr/lib/x86_64-linux-gnu/libidn2* /usr/lib/x86_64-linux-gnu/
COPY --from=fluentbit /usr/lib/x86_64-linux-gnu/libunistring* /usr/lib/x86_64-linux-gnu/
COPY --from=fluentbit /usr/lib/x86_64-linux-gnu/libtasn1* /usr/lib/x86_64-linux-gnu/
COPY --from=fluentbit /usr/lib/x86_64-linux-gnu/libnettle* /usr/lib/x86_64-linux-gnu/
COPY --from=fluentbit /usr/lib/x86_64-linux-gnu/libhogweed* /usr/lib/x86_64-linux-gnu/
COPY --from=fluentbit /usr/lib/x86_64-linux-gnu/libgmp* /usr/lib/x86_64-linux-gnu/
COPY --from=fluentbit /usr/lib/x86_64-linux-gnu/libffi* /usr/lib/x86_64-linux-gnu/
COPY --from=fluentbit /lib/x86_64-linux-gnu/libcom_err* /lib/x86_64-linux-gnu/
COPY --from=fluentbit /lib/x86_64-linux-gnu/libkeyutils* /lib/x86_64-linux-gnu/

COPY --from=fluentbit /fluent-bit /fluent-bit
COPY docker-mods/rclone-rotate-service-account/root/ /
