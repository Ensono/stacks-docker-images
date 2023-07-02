ARG ERD_GOLANG_VERSION=1.15
ARG IMAGE_REF=amidostacks/runner-pwsh-java
FROM $IMAGE_REF as base

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Minimal image with asciidoctor
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

FROM base AS main-minimal
RUN echo "assemble minimal main image" # keep here to help --cache-from along

ARG asciidoctor_version=2.0.20
ARG asciidoctor_pdf_version=2.3.9

ENV ASCIIDOCTOR_VERSION=${asciidoctor_version} \
    ASCIIDOCTOR_PDF_VERSION=${asciidoctor_pdf_version}

## Always use the latest Ruby version available for the current Alpine distribution
# hadolint ignore=DL3018
RUN apk add --no-cache ruby \
  && gem install --no-document \
  "asciidoctor:${ASCIIDOCTOR_VERSION}" \
  "asciidoctor-pdf:${ASCIIDOCTOR_PDF_VERSION}"

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Install erd-go (https://github.com/kaishuu0123/erd-go) as replacement for erd (https://github.com/BurntSushi/erd)
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
FROM golang:${ERD_GOLANG_VERSION}-alpine as erd-builder
ARG ERD_VERSION=v2.0.0

# go install or go get cannot be used the go.mod syntax of erd-go is not following the Golang semver properties,
# leading to errors whatever method is used.
# This fixes it by using a go build method to generate the binary instead.
# hadolint ignore=DL3018
RUN apk add --no-cache git \
  && git clone https://github.com/kaishuu0123/erd-go -b "${ERD_VERSION}" /app
WORKDIR /app
RUN CGO_ENABLED=0 GOOS=linux go build

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Final image
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
FROM main-minimal AS main
RUN echo "assemble comprehensive main image" # keep here to help --cache-from along

## Always use the latest dependencies versions available for the current Alpine distribution
# hadolint ignore=DL3018,DL3013,DL3028
RUN apk add --no-cache \
  ca-certificates \
  findutils \
  font-bakoma-ttf \
  graphviz \
  inotify-tools \
  make \
  py3-cairo \
  py3-pillow \
  py3-setuptools \
  ruby-bigdecimal \
  ruby-mathematical \
  ruby-rake \
  ttf-liberation \
  ttf-dejavu \
  which \
  font-noto-cjk \
  xz \
  imagemagick \
  gcompat

ARG PANDOC_VERSION=3.1.2
ARG HUGO_VERSION=0.111.3
ARG GO_VERSION=1.19.2
ARG asciidoctor_confluence_version=0.0.2
ARG asciidoctor_diagram_version=2.2.9
ARG asciidoctor_epub3_version=1.5.1
ARG asciidoctor_fb2_version=0.7.0
ARG asciidoctor_mathematical_version=0.3.5
ARG asciidoctor_revealjs_version=5.0.1
ARG kramdown_asciidoc_version=2.1.0
ARG asciidoctor_bibtex_version=0.8.0
ARG asciidoctor_kroki_version=0.8.0
ARG asciidoctor_reducer_version=1.0.2

ENV ASCIIDOCTOR_CONFLUENCE_VERSION=${asciidoctor_confluence_version} \
    ASCIIDOCTOR_DIAGRAM_VERSION=${asciidoctor_diagram_version} \
    ASCIIDOCTOR_EPUB3_VERSION=${asciidoctor_epub3_version} \
    ASCIIDOCTOR_FB2_VERSION=${asciidoctor_fb2_version} \
    ASCIIDOCTOR_MATHEMATICAL_VERSION=${asciidoctor_mathematical_version} \
    ASCIIDOCTOR_REVEALJS_VERSION=${asciidoctor_revealjs_version} \
    KRAMDOWN_ASCIIDOC_VERSION=${kramdown_asciidoc_version} \
    ASCIIDOCTOR_BIBTEX_VERSION=${asciidoctor_bibtex_version} \
    ASCIIDOCTOR_KROKI_VERSION=${asciidoctor_kroki_version} \
    ASCIIDOCTOR_REDUCER_VERSION=${asciidoctor_reducer_version}

RUN apk add --no-cache --virtual .rubymakedepends \
  build-base \
  libxml2-dev \
  ruby-dev

RUN gem install --no-document \
  "asciidoctor-confluence:${ASCIIDOCTOR_CONFLUENCE_VERSION}" \
  "asciidoctor-diagram:${ASCIIDOCTOR_DIAGRAM_VERSION}" \
  "asciidoctor-epub3:${ASCIIDOCTOR_EPUB3_VERSION}" \
  "asciidoctor-fb2:${ASCIIDOCTOR_FB2_VERSION}" \
  "asciidoctor-mathematical:${ASCIIDOCTOR_MATHEMATICAL_VERSION}" \
  asciimath \
  "asciidoctor-revealjs:${ASCIIDOCTOR_REVEALJS_VERSION}" \
  coderay \
  epubcheck-ruby:4.2.4.0 \
  haml \
  "kramdown-asciidoc:${KRAMDOWN_ASCIIDOC_VERSION}" \
  pygments.rb \
  rouge \
  slim \
  thread_safe \
  tilt \
  text-hyphen \
  "asciidoctor-bibtex:${ASCIIDOCTOR_BIBTEX_VERSION}" \
  "asciidoctor-kroki:${ASCIIDOCTOR_KROKI_VERSION}" \
  "asciidoctor-reducer:${ASCIIDOCTOR_REDUCER_VERSION}" \
  barby \
  rqrcode \
  prawn-icon \
  && apk del -r --no-cache .rubymakedepends
  
RUN apk add --no-cache --virtual .pythonmakedepends \
    build-base \
  libjpeg \
  jpeg-dev \
  zlib-dev \    
  freetype-dev \
  && pip3 install --no-cache-dir \
  actdiag \
  'blockdiag[pdf]' \
  nwdiag \
  seqdiag \
  && apk del -r --no-cache .pythonmakedepends

COPY --from=erd-builder /app/erd-go /usr/local/bin/
# for backward compatibility
RUN ln -snf /usr/local/bin/erd-go /usr/local/bin/erd

RUN curl -L https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-linux-amd64.tar.gz -o /tmp/pandoc.tar.gz && \
    tar zxf /tmp/pandoc.tar.gz -C /usr/bin pandoc-${PANDOC_VERSION}/bin/pandoc && \
    rm -rf /tmp/pandoc.tar.gz

# Install Go and Hugo
ENV PATH="${PATH}:/usr/local/go/bin"
RUN curl -L https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz -o /tmp/go.tar.gz && \
    tar zxf /tmp/go.tar.gz -C /usr/local && \
    rm -rf /tmp/go.tar.gz

RUN curl -L https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz -o /tmp/hugo.tar.gz && \
    tar zxf /tmp/hugo.tar.gz -C /usr/bin hugo && \
    ln -sf /lib/libgcompat.so.0 /usr/lib/libresolv.so.2 && \
    rm -rf /tmp/hugo.tar.gz

EXPOSE 1313