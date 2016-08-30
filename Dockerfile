FROM alpine:edge
MAINTAINER Patrick Double <pat@patdouble.com>

#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################

# Set correct environment variables
ENV HOME="/root" LC_ALL="C.UTF-8" LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8" TERM=dumb GLIBC_VERSION=2.23-r3 VERSION=8.4.21

# Use baseimage-docker's init system
# CMD ["/sbin/my_init"]
# Use Supervisor
CMD ["supervisord", "-c", "/etc/supervisor.conf", "-n"]

#########################################
##         RUN INSTALL SCRIPT          ##
#########################################

COPY * /tmp/
RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing --allow-untrusted libstdc++ curl ca-certificates bash supervisor shadow python2 && \
    for pkg in glibc-${GLIBC_VERSION} glibc-bin-${GLIBC_VERSION} glibc-i18n-${GLIBC_VERSION}; do curl -sSL https://github.com/andyshinn/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/${pkg}.apk -o /tmp/${pkg}.apk; done && \
    apk add --allow-untrusted /tmp/*.apk && \
    rm -v /tmp/*.apk && \
    ( /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true ) && \
    echo "export LANG=C.UTF-8" > /etc/profile.d/locale.sh && \
    /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib && \
    echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf && \
    chmod +x /tmp/install.sh && /tmp/install.sh && \
    apk del curl glibc-i18n && \
    rm -rf /tmp/* /var/cache/apk/*


#########################################
##         EXPORTS AND VOLUMES         ##
#########################################

EXPOSE 17500
VOLUME /home/.dropbox /home/Dropbox
