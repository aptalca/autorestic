FROM ghcr.io/linuxserver/baseimage-alpine:3.22

LABEL maintainer="aptalca"
LABEL org.opencontainers.image.source=https://github.com/aptalca/autorestic

ARG APP_VERSIONS

ENV HOME="/config"

RUN \
  echo "**** install runtime packages ****" && \
  apk add --no-cache --upgrade \
    bzip2 \
    logrotate \
    screen && \
  echo "**** install restic and autorestic ****" && \
  if [ -z "${APP_VERSIONS+x}" ]; then \
    RESTIC_RELEASE=$(curl -sX GET "https://api.github.com/repos/restic/restic/releases/latest" \
      | jq -r '.tag_name' | sed 's|^v||'); \
    AUTORESTIC_RELEASE=$(curl -sX GET "https://api.github.com/repos/cupcakearmy/autorestic/releases/latest" \
      | jq -r '.tag_name' | sed 's|^v||'); \
  else \
    RESTIC_RELEASE=$(echo "${APP_VERSIONS}" | sed 's|-.*||'); \
    AUTORESTIC_RELEASE=$(echo "${APP_VERSIONS}" | sed 's|.*-||'); \
  fi && \
  curl -fL "https://github.com/restic/restic/releases/download/v${RESTIC_RELEASE}/restic_${RESTIC_RELEASE}_linux_amd64.bz2" \
    | bzip2 -d > /usr/local/bin/restic && \
  curl -fL "https://github.com/cupcakearmy/autorestic/releases/download/v${AUTORESTIC_RELEASE}/autorestic_${AUTORESTIC_RELEASE}_linux_amd64.bz2" \
    | bzip2 -d > /usr/local/bin/autorestic && \
  chmod +x \
    /usr/local/bin/restic \
    /usr/local/bin/autorestic && \
  echo "**** fix logrotate ****" && \
  sed -i "s#/var/log/messages {}.*# #g" /etc/logrotate.conf && \
  sed -i 's,/usr/sbin/logrotate /etc/logrotate.conf,/usr/sbin/logrotate /etc/logrotate.conf -s /config/logrotate.status,g' \
    /etc/periodic/daily/logrotate && \
  rm -rf \
    /tmp/*

# add local files
COPY /root /
