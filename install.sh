#!/bin/sh -ex

#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################

#########################################
##    REPOSITORIES AND DEPENDENCIES    ##
#########################################

# Configure user nobody to match unRAID's settings
usermod -u 99 nobody
usermod -g 100 nobody
usermod -d /home nobody
find /home -xdev -not \( -user nobody -a -group users \) -a -not -path /home/Dropbox -exec chown nobody:users {} +
[ -d '/home/Dropbox' ] && chmod a+rx /home/Dropbox
[ -d '/home/Dropbox' ] && find /home/Dropbox -xdev -not -readable -exec chgrp users {} +

# Disable SSH
rm -rf /etc/service/sshd /etc/service/cron /etc/service/syslog-ng /etc/my_init.d/00_regen_ssh_host_keys.sh

#########################################
##  FILES, SERVICES AND CONFIGURATION  ##
#########################################
# CONFIG
mkdir /opt
cat <<'EOT' > /opt/config.sh
#!/bin/sh
# Fix the timezone
if [[ $(cat /etc/timezone) != $TZ ]] ; then
  echo "$TZ" > /etc/timezone
  dpkg-reconfigure -f noninteractive tzdata
fi
find /home -xdev -not \( -user nobody -a -group users \) -a -not -path /home/Dropbox -exec chown nobody:users {} +
[ -d '/home/Dropbox' ] && chmod a+rx /home/Dropbox
[ -d '/home/Dropbox' ] && find /home/Dropbox -xdev -not -readable -exec chgrp users {} +
sleep 5
exit 0
EOT

# Dropbox
cat <<'EOT' > /opt/dropbox.sh
#!/bin/sh

#  Dropbox did not shutdown properly? Remove files.
[ ! -e "/home/.dropbox/command_socket" ] || rm /home/.dropbox/command_socket
[ ! -e "/home/.dropbox/iface_socket" ]   || rm /home/.dropbox/iface_socket
[ ! -e "/home/.dropbox/unlink.db" ]      || rm /home/.dropbox/unlink.db
[ ! -e "/home/.dropbox/dropbox.pid" ]    || rm /home/.dropbox/dropbox.pid

exec ionice -c 3 nice /home/.dropbox-dist/dropboxd
EOT

# DropboxStatus
cat <<'EOT' > /opt/dropbox_status.sh
#!/bin/sh

if [ "$STATUS" != "Yes" ]; then
  echo "Continous console status not requested"
  sleep 5;
  exit 0
else
  while [ ! -e "/home/.dropbox/iface_socket" ]; do sleep 1; done
  exec /opt/dropbox_status.py
fi
EOT

cat <<'EOT' > /etc/supervisor.conf
[supervisord]
nodaemon=true
umask = 000

[program:config]
priority = 1
startsecs = 0
autorestart = False
command = /opt/config.sh

[program:Dropbox]
priority = 998
user = nobody
group = users
directory= /home
environment = HOME="/home"
startsecs = 1
autorestart = True
command = /opt/dropbox.sh
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0

[program:DropboxStatus]
priority = 999
user = nobody
directory=/home
environment = HOME="/home"
startsecs = 1
autorestart = True
command = /opt/dropbox_status.sh
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
EOT

mv /tmp/dropbox_status.py /opt/dropbox_status.py
chmod +x /opt/*.sh /opt/dropbox_status.py

#########################################
##             INSTALLATION            ##
#########################################

# Install Dropbox
#URL="https://dl.dropboxusercontent.com/u/17/dropbox-lnx.x86_64-${VERSION}.tar.gz"
URL="https://www.dropbox.com/download?plat=lnx.x86_64"
curl -L ${URL} | tar -xzf - -C /home
find /home -xdev -not \( -user nobody -a -group users \) -a -not -path /home/Dropbox -exec chown nobody:users {} +
[ -d '/home/Dropbox' ] && chmod a+rx /home/Dropbox
[ -d '/home/Dropbox' ] && find /home/Dropbox -xdev -not -readable -exec chgrp users {} +

#########################################
##                 CLEANUP             ##
#########################################

# Clean install files
rm -rf /var/cache/* /var/tmp/*

