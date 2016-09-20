dropbox-container
=================
[![](https://images.microbadger.com/badges/image/pdouble16/dropbox-container.svg)](https://microbadger.com/images/pdouble16/dropbox-container "Get your own image badge on microbadger.com") [![](https://images.microbadger.com/badges/version/pdouble16/dropbox-container.svg)](https://microbadger.com/images/pdouble16/dropbox-container "Get your own image badge on microbadger.com") [![](https://images.microbadger.com/badges/commit/pdouble16/dropbox-container.svg)](https://microbadger.com/images/pdouble16/dropbox-container "Get your own image badge on microbadger.com") [![](https://images.microbadger.com/badges/license/pdouble16/dropbox-container.svg)](https://microbadger.com/images/pdouble16/dropbox-container "Get your own image badge on microbadger.com")

This is a Dockerfile setup for Dropbox - https://www.dropbox.com

To run:

```shell
docker run -d --name="dropbox" --privileged=true --net="host" -v /path/to/your/config:/home/.dropbox -v /path/to/your/files:/home/Dropbox -v /etc/localtime:/etc/localtime:ro gfjardim/dropbox
```

