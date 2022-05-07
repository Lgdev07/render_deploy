FROM hexpm/elixir:1.13.0-erlang-23.3.4.10-alpine-3.14.3 AS base

WORKDIR /render_deploy

RUN mix do local.hex --force, local.rebar --force

RUN apk add npm inotify-tools

# -----------------
# BUILD
# -----------------
FROM base AS build

RUN apk add curl bash git

ARG MIX_ENV=prod
ENV MIX_ENV=$MIX_ENV
COPY . ./

# install application
RUN mix do deps.get, compile

# -----------------
# RELEASE
# -----------------
FROM build AS release

# digests and compresses static files
RUN mix assets.deploy

# generate release executable
RUN mix release

# -----------------
# PRODUCTION
# -----------------
FROM alpine:3.14.3

WORKDIR /render_deploy

ARG MIX_ENV=prod

# install dependencies
RUN apk add ncurses-libs curl

COPY --from=release /render_deploy/_build/$MIX_ENV/rel/render_deploy ./

# start application
CMD ["bin/render_deploy", "start"]