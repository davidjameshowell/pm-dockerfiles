ARG OUTPUT=/output
FROM alpine:edge AS builder
RUN apk add --no-cache \
    autoconf \
    automake \
    binutils \
    cmake \
    curl \
    dpkg \
    file \
    g++ \
    gcc \
    git \
    libc6-compat \
    libdrm-dev \
    libtool \
    libxshmfence \
    linux-headers \
    make \
    mesa-va-gallium \
    musl-dev \
    nghttp2-dev \
    pkgconfig \
    xxd

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FROM builder AS amd

ARG CFLAGS
ARG LDFLAGS
ARG MAKEFLAGS
ARG OUTPUT
ARG DESTDIR

WORKDIR /tmp/amd

RUN ls -la /usr/lib/

RUN apk add  xf86-video-amdgpu linux-firmware-amdgpu --no-cache --update-cache \
 && apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing libva-utils \
 && mkdir -p "$OUTPUT/usr/bin" \
 && cp -a /usr/bin/vainfo "$OUTPUT/usr/bin" \
 && mkdir -p "$OUTPUT/usr/lib" \
 && cp -a /usr/lib/libX*.so* "$OUTPUT/usr/lib" \
 && cp -a /usr/lib/libwayland*.so* "$OUTPUT/usr/lib" \
 && cp -a /usr/lib/libva*.so* "$OUTPUT/usr/lib" \
 && cp -a /usr/lib/libdrm*.so* "$OUTPUT/usr/lib" \
 && cp -a /usr/lib/libbsd*.so* "$OUTPUT/usr/lib" \
 && cp -a /usr/lib/libxshmfence*.so* "$OUTPUT/usr/lib" \
 # && cp -a /usr/lib/libkms*.so* "$OUTPUT/usr/lib" \
 && cp -a /usr/lib/libxcb*.so* "$OUTPUT/usr/lib" \
 && cp -a /usr/lib/libffi*.so* "$OUTPUT/usr/lib" \
 && cp -a /usr/lib/libLLVM*.so* "$OUTPUT/usr/lib" \
 && cp -a /usr/lib/libzstd*.so* "$OUTPUT/usr/lib" \
 && cp -a /usr/lib/libexpat*.so* "$OUTPUT/usr/lib" \
 && cp -a /usr/lib/libelf*.so* "$OUTPUT/usr/lib" \
 && cp -a /usr/lib/libstdc++*.so* "$OUTPUT/usr/lib" \
 && cp -a /usr/lib/libgcc_s*.so* "$OUTPUT/usr/lib" \
 && cp -a /usr/lib/libmd*.so* "$OUTPUT/usr/lib" \
 && cp -a /usr/lib/libxml2*.so* "$OUTPUT/usr/lib" \
 && mkdir -p "$OUTPUT/usr/lib/dri" \
 && cp -a /usr/lib/dri/*.so* "$OUTPUT/usr/lib/dri" \
 && mkdir -p "$OUTPUT/usr/share/libdrm" \
 && cp -a /usr/share/libdrm/* "$OUTPUT/usr/share/libdrm" \
 && cp -a /lib/ld-musl-x86_64.so.1 "$OUTPUT/usr/lib" \
 && cp -a /lib/libz*.so* "$OUTPUT/usr/lib"

ARG LSIO_IMAGE_VERSION=version-1.32.5.7349-8f4248874
FROM alpine:3.18.3 AS buildstage

ARG RCLONE_VERSION=${RCLONE_VERSION:-v1.63.1}
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

## Start LSIO Image Build
FROM linuxserver/plex:$LSIO_IMAGE_VERSION
ARG OUTPUT

COPY --from=buildstage /root-layer/ /
COPY docker-mods/rclone-rotate-service-account/root/ /
COPY docker-mods/pm-plex-base/root/ /

# Copy lib files
COPY --from=amd $OUTPUT/usr/lib/dri/*.so* /usr/lib/plexmediaserver/lib/dri/
COPY --from=amd $OUTPUT/usr/lib/ld-musl-x86_64.so* /usr/lib/plexmediaserver/lib/
COPY --from=amd $OUTPUT/usr/lib/libdrm*.so* /usr/lib/plexmediaserver/lib/
COPY --from=amd $OUTPUT/usr/lib/libelf*.so* /usr/lib/plexmediaserver/lib/
COPY --from=amd $OUTPUT/usr/lib/libffi*.so* /usr/lib/plexmediaserver/lib/
COPY --from=amd $OUTPUT/usr/lib/libgcc_s*.so* /usr/lib/plexmediaserver/lib/
# COPY --from=amd $OUTPUT/usr/lib/libkms*.so* /usr/lib/plexmediaserver/lib/
COPY --from=amd $OUTPUT/usr/lib/libLLVM*.so* /usr/lib/plexmediaserver/lib/
COPY --from=amd $OUTPUT/usr/lib/libstdc++*.so* /usr/lib/plexmediaserver/lib/
COPY --from=amd $OUTPUT/usr/lib/libva*.so* /usr/lib/plexmediaserver/lib/
COPY --from=amd $OUTPUT/usr/lib/libxml2*.so* /usr/lib/plexmediaserver/lib/
COPY --from=amd $OUTPUT/usr/lib/libz*.so.* /usr/lib/plexmediaserver/lib/
COPY --from=amd $OUTPUT/usr/lib/libzstd*.so* /usr/lib/plexmediaserver/lib/

# Install AMD drivers
RUN apt-get update \
 && apt-get install -y software-properties-common

RUN add-apt-repository ppa:oibaf/graphics-drivers -y
RUN curl -sL --retry 3 https://repo.radeon.com/rocm/rocm.gpg.key | apt-key add - \
 && add-apt-repository "deb https://repo.radeon.com/rocm/apt/latest $(lsb_release -s -c) main" -y

RUN apt-get update \
 && apt-get install -y \
	vainfo \
	mesa-va-drivers \
	mesa-vdpau-drivers \
	libdrm-amdgpu1 \
	libavutil56 \
	rocm-opencl-runtime \
 && apt-get clean

HEALTHCHECK --interval=10s --timeout=8s CMD /healthcheck.sh || exit 1
