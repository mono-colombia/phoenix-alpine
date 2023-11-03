FROM hexpm/elixir:1.15.7-erlang-25.3.2.7-alpine-3.17.5
LABEL maintainer="Jhon Pedroza <jpedroza@cuentamono.com>"

ENV PHOENIX_VERSION=1.6.15
# Try to appsignal on m1
ENV APPSIGNAL_BUILD_FOR_MUSL=1

# Base packages and nodejs
RUN apk add --no-cache --update \
  bash gcc \
  libc-dev git nodejs npm inotify-tools \
  ca-certificates openssl-dev make automake \
  autoconf musl musl-dev gnupg neovim

# PDF tools
RUN apk --no-cache add -U weasyprint py3-brotli poppler-utils
# Wallaby tests
RUN apk add --update-cache g++ chromium chromium-chromedriver

RUN mkdir -p /usr/share/fonts/TTF
RUN wget -O /usr/share/fonts/TTF/Lato-Regular.ttf https://mono-colombia-public.s3.amazonaws.com/fonts/Lato-Regular.ttf

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
RUN touch ~/.bashrc
RUN echo 'alias vim=nvim' >> ~/.bashrc
RUN /bin/bash -c "mix local.hex --force"
RUN /bin/bash -c "mix local.rebar --force"
RUN /bin/bash -c "mix archive.install --force hex phx_new $PHOENIX_VERSION"
