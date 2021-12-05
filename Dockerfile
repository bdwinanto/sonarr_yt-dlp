FROM python:alpine

LABEL maintainer="Martin Jones <whatdaybob@outlook.com>"

ARG UID=1000
ARG GID=1000
ARG UNAME=abc

# Update and install ffmpeg
RUN apk update && \
    apk add --no-cache ffmpeg alpine-sdk

RUN mkdir /config /app /sonarr_root /logs && \
    touch /var/lock/sonarr_youtube.lock

# add local files
COPY app/ /app
# update file permissions
RUN \
    chmod a+x \
    /app/sonarr_youtubedl.py \
    /app/utils.py \
    /app/config.yml.template

RUN pip install --upgrade pip
RUN adduser -D $UNAME
USER $UNAME
WORKDIR /home/$UNAME

# Copy and install requirements
COPY --chown=$UID:$GID requirements.txt requirements.txt
RUN pip install --user -r requirements.txt

ENV PATH="/home/$UNAME/.local/bin:${PATH}"

COPY --chown=$UID:$GID . .

# add volumes
VOLUME /config
VOLUME /sonarr_root
VOLUME /logs

# ENV setup
ENV CONFIGPATH /config/config.yml
CMD [ "python", "-u", "/app/sonarr_youtubedl.py" ]
