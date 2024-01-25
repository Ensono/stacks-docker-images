ARG IMAGE_REF=amidostacks/runner-pwsh
FROM $IMAGE_REF as base

FROM golang:1.22rc2-alpine3.18

COPY files/unittests.sh /usr/local/bin

RUN go install github.com/jstemmer/go-junit-report@latest && \
    go install github.com/t-yuki/gocover-cobertura@latest && \
    go install github.com/axw/gocov/gocov@latest && \
    go install github.com/AlekSi/gocov-xml@latest && \
    chmod +x /usr/local/bin/unittests.sh

# Install PowerShell dependencies
RUN apk add --no-cache \
    ca-certificates \
    less \
    ncurses-terminfo-base \
    krb5-libs \
    libgcc \
    libintl \
    libssl1.1 \
    libstdc++ \
    tzdata \
    userspace-rcu \
    zlib \
    icu-libs

RUN apk -X https://dl-cdn.alpinelinux.org/alpine/edge/main add --no-cache \
    lttng-ust

# Copy PowerShell and required modules from the base image
COPY --from=base /opt/microsoft /opt/microsoft
COPY --from=base /modules/EnsonoBuild /modules/EnsonoBuild

ENV PATH="${PATH}:/opt/microsoft/powershell/7"
