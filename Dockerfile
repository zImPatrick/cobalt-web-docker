FROM node:23-alpine AS build
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

# https://github.com/imputnet/cobalt/tree/main/web#environment-variables
ARG WEB_HOST
ARG WEB_DEFAULT_API

# hack to reference the cobalt git repo without being in it ourselves
WORKDIR /app
COPY --from=cobalt-src . .

RUN corepack enable
RUN apk add --no-cache git

# this totally fucks up the git repo but it breaks cobalt otherwise
# https://github.com/imputnet/cobalt/blob/4b9644ebdfbfe7bc6f7ec2d476692e3619cb59bd/packages/version-info/index.js#L30
RUN echo "0000000000000000000000000000000000000000 $(git rev-parse HEAD)" > .git/logs/HEAD

# don't need to install anything other than the web deps
# (but we need the root folder for the workspace)
RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
  pnpm install --frozen-lockfile --filter=./web
RUN pnpm run --filter=./web build

FROM busybox:1.37 AS web
WORKDIR /app
COPY --from=build /app/web/build .

COPY ./fixup.sh .
RUN chmod +x ./fixup.sh && ./fixup.sh && rm ./fixup.sh

COPY ./httpd.conf /etc/httpd.conf

EXPOSE 3000
CMD ["busybox", "httpd", "-f", "-p", "3000"]
