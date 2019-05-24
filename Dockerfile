################################################################################
## STEP 1 - GET DEPS
FROM elixir:1.8-slim as builder

ENV MIX_ENV=prod

# install git
RUN apt-get update; \
    apt-get install -y build-essential; \
    apt-get install -y git; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*_*

# make directory
RUN mkdir /app
WORKDIR /app

# elixir copy mix
ENV MIX_ENV=prod
RUN mkdir /app/_build/ /app/config/ /app/lib/ /app/priv/ /app/deps/ /app/rel/
COPY mix.exs /app/mix.exs
COPY mix.lock /app/mix.lock

# install rebar and hex
RUN mix local.rebar --force
RUN mix local.hex --force

COPY config /app/config
COPY lib /app/lib
COPY priv /app/priv
COPY rel /app/rel

# install deps
RUN mix do deps.get --only $MIX_ENV

################################################################################
# STEP 2 - RELEASE BUILDER
FROM elixir:1.8.1-alpine AS releaser

# setup up variables
ARG APP_NAME
ARG APP_VSN

ENV APP_NAME=${APP_NAME} \
    APP_VSN=${APP_VSN} 

ENV MIX_ENV=prod

RUN mkdir -p /app
WORKDIR /app
COPY --from=builder /app /app

# This step installs all the build tools we'll need
RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache \
    git \
    build-base && \
    mix local.rebar --force && \
    mix local.hex --force

RUN mix do deps.compile, compile

# create release
RUN mkdir -p /opt/built && \
    mix release --verbose && \
    cp _build/prod/rel/${APP_NAME}/releases/${APP_VSN}/${APP_NAME}.tar.gz /opt/built && \
    cd /opt/built && \ 
    tar -xzf /opt/built/${APP_NAME}.tar.gz &&\
    rm ${APP_NAME}.tar.gz

################################################################################
## STEP 3 - FINAL
FROM alpine:3.9

ENV MIX_ENV=prod

RUN apk update && \
    apk add --no-cache \
    bash \
    openssl-dev

COPY --from=releaser /opt/built /app
WORKDIR /app
