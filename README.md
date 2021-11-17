dropbox-container
=================
[![](https://images.microbadger.com/badges/image/pdouble16/dropbox-container.svg)](https://microbadger.com/images/pdouble16/dropbox-container "Get your own image badge on microbadger.com") [![](https://images.microbadger.com/badges/version/pdouble16/dropbox-container.svg)](https://microbadger.com/images/pdouble16/dropbox-container "Get your own image badge on microbadger.com") [![](https://images.microbadger.com/badges/commit/pdouble16/dropbox-container.svg)](https://microbadger.com/images/pdouble16/dropbox-container "Get your own image badge on microbadger.com") [![](https://images.microbadger.com/badges/license/pdouble16/dropbox-container.svg)](https://microbadger.com/images/pdouble16/dropbox-container "Get your own image badge on microbadger.com")

This is a container for Dropbox - (https://www.dropbox.com)[dropbox.com]. The latest client is installed on the first
start of the container and thereafter the client updates itself.

The goal is to have a small image, therefore Alpine is used as a base.

To run:

```shell
docker run -d --name="dropbox" --privileged=true --net="host" -v /path/to/your/config:/home/.dropbox -v /path/to/your/files:/home/Dropbox -v /etc/localtime:/etc/localtime:ro pdouble16/dropbox-container
```

