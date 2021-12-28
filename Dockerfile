FROM thobe/wkhtmltopdf-base:latest as wkhtmltopdf

FROM alpine:3.14
LABEL maintainer="Jhon Pedroza <jpedroza@cuentamono.com>"
ENV ERLANG_VERSION=24.2
# elixir 1.13.1
ENV ELIXIR_COMMIT=33f9d04851a2664aeae5f5f78eeef9e5b4c38030
ENV NODE_VERSION=14.18.1
ENV PHOENIX_VERSION=1.6.4

RUN \
    apk add --no-cache --update \
      bash \
      ca-certificates \
      openssl-dev \
      ncurses-dev \
      unixodbc-dev \
      zlib-dev curl gcc \
      make automake \
      libxml2-utils \
      autoconf gnupg nodejs npm \
      inotify-tools
RUN \
    apk add --no-cache \
      dpkg-dev \
      dpkg \
      binutils \
      git \
      autoconf \
      build-base \
      make \
      automake \
      autoconf \
      gcc \
      grep \
      perl-dev \
      poppler-utils
  RUN apk --no-cache add -U musl musl-dev ncurses-libs libssl1.1 libressl3.3-libcrypto bash \
      qt5-qtwebkit qt5-qtbase-x11 qt5-qtsvg qt5-qtdeclarative qt5-qtsvg qt5-qtbase
  RUN apk add --update-cache \
      xvfb \
      dbus \
      ttf-freefont \
      fontconfig && \
      apk add --update-cache \
          --repository http://dl-cdn.alpinelinux.org/alpine/v3.13/community/ \
          --allow-untrusted \
      wkhtmltopdf && \
      rm -rf /var/cache/apk/* && \
      chmod +x /usr/bin/wkhtmltopdf && \
      apk add g++ chromium \
      chromium-chromedriver

COPY --from=wkhtmltopdf /bin/wkhtmltopdf usr/bin/wkhtmltopdf

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
RUN touch ~/.bashrc
RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf
ENV KERL_CONFIGURE_OPTIONS --without-debugger --without-observer --disable-silent-rules --without-javac --enable-shared-zlib --enable-dynamic-ssl-lib --enable-hipe --enable-smp-support --enable-threads --enable-kernel-poll --enable-wx --disable-debug --without-javac --enable-darwin-64bit
RUN cd ~/.asdf && git checkout "$(git describe --abbrev=0 --tags)"
ENV PATH /root/.asdf/bin:/root/.asdf/shims:${PATH}
RUN /bin/bash -c "source ~/.bashrc"
RUN /bin/bash -c "asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git"
RUN /bin/bash -c "asdf install erlang $ERLANG_VERSION"
RUN /bin/bash -c "asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git"
RUN /bin/bash -c "asdf global erlang $ERLANG_VERSION"
RUN /bin/bash -c "asdf install elixir ref:$ELIXIR_COMMIT"
RUN /bin/bash -c "asdf global elixir ref:$ELIXIR_COMMIT"
RUN /bin/bash -c "mix local.hex --force"
RUN /bin/bash -c "mix local.rebar --force"
RUN /bin/bash -c "mix archive.install --force hex phx_new $PHOENIX_VERSION"
