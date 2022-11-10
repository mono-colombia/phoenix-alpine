FROM hexpm/elixir:1.14.0-erlang-24.3.4.5-alpine-3.16.2
LABEL maintainer="Jhon Pedroza <jpedroza@cuentamono.com>"

ENV PHOENIX_VERSION=1.6.12
# Try to appsignal on m1
ENV APPSIGNAL_BUILD_FOR_MUSL=1

# Add edge repository
RUN echo "@edge http://dl-cdn.alpinelinux.org/alpine/edge/main">>/etc/apk/repositories
# Base packages and nodejs
RUN apk add --no-cache --update \
  bash gcc \
  libc-dev git nodejs npm inotify-tools \
  ca-certificates openssl-dev make automake \
  autoconf musl musl-dev neovim gnupg@edge

# PDF tools
RUN apk --no-cache add -U weasyprint py3-brotli poppler-utils
# Wallaby tests
RUN apk add --update-cache g++ chromium chromium-chromedriver

RUN wget -O /usr/share/fonts/TTF/Lato-Regular.ttf https://mono-colombia-public.s3.amazonaws.com/fonts/Lato-Regular.ttf

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
RUN touch ~/.bashrc
RUN echo 'alias vim=nvim' >> ~/.bashrc
RUN /bin/bash -c "mix local.hex --force"
RUN /bin/bash -c "mix local.rebar --force"
RUN /bin/bash -c "mix archive.install --force hex phx_new $PHOENIX_VERSION"
