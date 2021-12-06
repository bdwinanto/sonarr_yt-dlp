FROM python:alpine

LABEL maintainer="Martin Jones <whatdaybob@outlook.com>"

ARG UID=1000
ARG GID=1000
ARG UNAME=abc

RUN apk update && \
    apk add --no-cache ffmpeg build-base && \
    mkdir /config /app /sonarr_root /logs && \
    touch /var/lock/sonarr_youtube.lock

COPY app/ /app

RUN \
    chmod a+x \
    /app/sonarr_youtubedl.py \
    /app/utils.py \
    /app/config.yml.template

RUN pip install --upgrade pip

RUN adduser -D abc
USER abc
WORKDIR /home/abc

COPY --chown=abc:abc requirements.txt requirements.txt
RUN pip install --user -r requirements.txt

ENV PATH="/home/abc/.local/bin:${PATH}"

COPY --chown=abc:abc . .

VOLUME /config
VOLUME /sonarr_root
VOLUME /logs

ENV CONFIGPATH /config/config.yml
CMD [ "python", "-u", "/app/sonarr_youtubedl.py" ]
