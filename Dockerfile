FROM ubuntu:22.04

ARG SOURCE_COMMIT
ARG DOCKERFILE_PATH
ARG SOURCE_TYPE
ARG VERSION=163.4.5456
ARG APT_PROXY

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

COPY install.sh /tmp/
RUN if [ -n "${APT_PROXY}" ]; then echo "Acquire::HTTP::Proxy \"${APT_PROXY}\";\nAcquire::HTTPS::Proxy false;\n" >> /etc/apt/apt.conf.d/01proxy; cat /etc/apt/apt.conf.d/01proxy; fi &&\
    apt-get update &&\
    # to find dependencies, download Ubuntu .deb from https://www.dropbox.com/install-linux, `deb -I dropbox.deb`
    apt-get install -y curl ca-certificates supervisor libatomic1 xserver-xorg-core librsync2 python3-gi libatk1.0-0 libcairo2 libglib2.0-0 libgtk-3-0 libpango1.0-0 gir1.2-gdkpixbuf-2.0 gir1.2-glib-2.0 gir1.2-gtk-3.0 gir1.2-pango-1.0 && \
    # https://github.com/moby/moby/issues/9547
    chmod +x /tmp/install.sh && sleep 3s && /tmp/install.sh && rm /tmp/install.sh && \
    apt-get clean && \
    rm -f /etc/apt/apt.conf.d/01proxy

ADD 'https://www.dropbox.com/download?dl=packages/dropbox.py' /home/dropbox.py

COPY dropbox_status.py /opt/dropbox_status.py
RUN chmod +x /opt/dropbox_status.py /home/dropbox.py

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

