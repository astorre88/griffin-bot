ARG ALPINE_VERSION=3.8

FROM elixir:1.7.2-alpine AS builder

ARG APP_NAME
ARG APP_VSN
ARG MIX_ENV=prod

ENV APP_NAME=${APP_NAME} \
    APP_VSN=${APP_VSN} \
    MIX_ENV=${MIX_ENV}

WORKDIR /opt/app

RUN apk update && \
  apk upgrade --no-cache && \
  apk add --no-cache \
    xvfb \
    ttf-freefont \
    fontconfig \
    dbus \
    git \
    build-base && \
  apk add qt5-qtbase-dev \
          wkhtmltopdf \
          --no-cache \
          --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ \
          --allow-untrusted \
  && \

  # Wrapper for xvfb
  mv /usr/bin/wkhtmltopdf /usr/bin/wkhtmltopdf-origin && \
  echo $'#!/usr/bin/env sh\n\
Xvfb :0 -screen 0 1024x768x24 -ac +extension GLX +render -noreset & \n\
DISPLAY=:0.0 wkhtmltopdf-origin $@ \n\
killall Xvfb\
' > /usr/bin/wkhtmltopdf && \
  chmod +x /usr/bin/wkhtmltopdf && \
  mix local.rebar --force && \
  mix local.hex --force

COPY . .

RUN mix do deps.get, deps.compile, compile

RUN \
  mkdir -p /opt/built && \
  mix release --verbose && \
  cp _build/${MIX_ENV}/rel/${APP_NAME}/releases/${APP_VSN}/${APP_NAME}.tar.gz /opt/built && \
  cd /opt/built && \
  tar -xzf ${APP_NAME}.tar.gz && \
  rm ${APP_NAME}.tar.gz

FROM alpine:${ALPINE_VERSION}

ARG APP_NAME

RUN apk update && \
    apk add --no-cache \
      bash \
      openssl-dev

ENV APP_NAME=${APP_NAME}

WORKDIR /opt/app

COPY --from=builder /opt/built .

CMD trap 'exit' INT; /opt/app/bin/${APP_NAME} foreground
