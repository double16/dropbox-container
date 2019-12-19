FROM ubuntu:18.04

ARG SOURCE_COMMIT
ARG DOCKERFILE_PATH
ARG SOURCE_TYPE
ARG VERSION=87.4.138

#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################

# Set correct environment variables
ENV HOME="/root" LC_ALL="C.UTF-8" LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8" TERM=dumb DEBIAN_FRONTEND=noninteractive

# Use Supervisor
CMD ["supervisord", "-c", "/etc/supervisor.conf", "-n"]

#########################################
##         RUN INSTALL SCRIPT          ##
#########################################

COPY * /tmp/
RUN apt-get update &&\
    apt-get install -y curl ca-certificates supervisor libatomic1 && \
    # https://github.com/moby/moby/issues/9547
    chmod +x /tmp/install.sh && sleep 3s && /tmp/install.sh && \
    apt-get clean

#########################################
##         EXPORTS AND VOLUMES         ##
#########################################

VOLUME /home/.dropbox /home/Dropbox

HEALTHCHECK CMD test -e /proc/$(</home/.dropbox/dropbox.pid) || exit 1

LABEL maintainer="Patrick Double <pat@patdouble.com>" \
      org.label-schema.docker.dockerfile="$DOCKERFILE_PATH/Dockerfile" \
      org.label-schema.license="GPLv2" \
      org.label-schema.name="Dropbox ${VERSION}" \
      org.label-schema.vendor="https://bitbucket.org/double16" \
      org.label-schema.url="https://bitbucket.org/double16/dropbox-container" \
      org.label-schema.vcs-ref=$SOURCE_COMMIT \
      org.label-schema.vcs-type="$SOURCE_TYPE" \
      org.label-schema.vcs-url="https://bitbucket.org/double16/dropbox-container.git"

