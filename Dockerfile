FROM hexpm/elixir:1.19.5-erlang-28.3.2-alpine-3.23.3
LABEL maintainer="Jhon Pedroza <jpedroza@mono.la>"

ENV PHOENIX_VERSION=1.7.21
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

# CPython 3.12 (already a transitive dep of weasyprint above; here we
# add the headers + pip so consumers can both link against libpython
# from a NIF and install additional Python packages system-wide).
#
# Extra libraries installed system-wide:
#   * py3-dateutil — common date/time helpers
#   * py3-pillow   — image library (shared with weasyprint)
#   * pdfplumber   — PDF text/table extraction (not in Alpine repos,
#                    installed via pip with --break-system-packages
#                    since the image is immutable)
#
# Pillow is pulled by apk before pip runs so pdfplumber reuses the
# system Pillow that weasyprint also depends on; this avoids two
# parallel installs racing for the same site-packages directory.
RUN apk --no-cache add python3 python3-dev py3-pip py3-dateutil py3-pillow
RUN pip3 install --break-system-packages --no-cache-dir "pdfplumber>=0.11.0"

RUN mkdir -p /usr/share/fonts/TTF
RUN wget -O /usr/share/fonts/TTF/Lato-Regular.ttf https://mono-colombia-public.s3.amazonaws.com/fonts/Lato-Regular.ttf

COPY ./certs/global_sign_ca.pem /usr/local/share/ca-certificates/global_sign_ca.crt
RUN update-ca-certificates

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
RUN touch ~/.bashrc
RUN echo 'alias vim=nvim' >> ~/.bashrc
RUN /bin/bash -c "mix local.hex --force"
RUN /bin/bash -c "mix local.rebar --force"
RUN /bin/bash -c "mix archive.install --force hex phx_new $PHOENIX_VERSION"
