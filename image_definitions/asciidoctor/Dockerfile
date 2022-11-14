FROM amidostacks/runner-pwsh

ARG PANDOC_VERSION=2.17.1.1

ENV GEM_FONTS_DIR=/usr/share/ruby-asciidoctor-pdf/data/fonts

VOLUME ["/data"]

# Install asciidoctor
RUN apt-get update && \
    apt-get install -y asciidoctor wget

# Install the asciidoctor-pdf command
RUN gem install --no-document asciidoctor-pdf

# Install pandoc
RUN wget https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-1-amd64.deb -O /tmp/pandoc.deb && \
    dpkg -i /tmp/pandoc.deb && \
    rm -rf /tmp/pandoc.deb

# Installed required gems
RUN gem install rouge --no-doc
