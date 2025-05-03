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

# don't need to install anything other than the web deps
# (but we need the root folder for the workspace)
RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
  pnpm install --frozen-lockfile --filter=./web
RUN pnpm run --filter=./web build

FROM busybox:1.37 AS web
WORKDIR /app
COPY --from=build /app/web/build .

EXPOSE 3000
CMD ["busybox", "httpd", "-f", "-v", "-p", "3000"]
