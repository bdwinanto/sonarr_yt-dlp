FROM python:alpine AS base

RUN apk update && \
    apk add --no-cache ffmpeg

#LABEL maintainer="Martin Jones <whatdaybob@outlook.com>"

FROM python:alpine AS dependencies

COPY requirements.txt ./
RUN apk update && \
    apk add --no-cache build-base && \
    pip install --upgrade pip && pip install -r requirements.txt

FROM base

ARG UID=1000 GID=1000 UNAME=abc

RUN adduser -D $UNAME
WORKDIR /home/$UNAME

COPY . /home/$UNAME
COPY --from=dependencies /root/.cache /root/.cache
COPY requirements.txt ./
RUN pip install --upgrade pip && pip install -r requirements.txt && rm -rf /root/.cache

RUN mkdir /config /sonarr_root /logs && \
    touch /var/lock/sonarr_youtube.lock
COPY app/ /app

RUN \
    chmod a+x \
    /app/sonarr_youtubedl.py \
    /app/utils.py \
    /app/config.yml.template

COPY --chown=$UID:$GID . .
USER $UNAME

VOLUME /config /sonarr_root /logs

ENV CONFIGPATH /config/config.yml
CMD [ "python", "-u", "/app/sonarr_youtubedl.py" ]
