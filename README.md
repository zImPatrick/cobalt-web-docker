# cobalt-web-docker

Docker container for [cobalt's web UI](https://github.com/imputnet/cobalt/tree/main/web). Builds the static files and hosts it with BusyBox's httpd.

## Usage

In a Docker Compose file:

```yaml
services:
  cobalt-web:
    build:
      context: https://github.com/NotNite/cobalt-web-docker.git
      dockerfile: Dockerfile
      additional_contexts:
        cobalt-src: https://github.com/imputnet/cobalt.git

      args:
        WEB_HOST: "http://localhost:3000/"
        WEB_DEFAULT_API: "http://localhost:9000/"

    ports:
      - 3000:3000/tcp
```

You must run your own cobalt API to use the frontend. For running your own cobalt API, [see the official docs](https://github.com/imputnet/cobalt/blob/main/docs/run-an-instance.md).

Note that the container listens on port `3000`, but you can of course map it to any other port (e.g. `42069:3000/tcp`). Make sure `WEB_HOST` is set to the user-facing URL of your frontend instance, and `WEB_DEFAULT_API` is set to the user-facing URL of your backend.

The `additional_contexts` line is a hack to reference the cobalt source code without the Dockerfile actually being in the source code. You can pin this to a specific commit or branch if you want (see [here](https://docs.docker.com/build/concepts/context/#git-repositories)).
