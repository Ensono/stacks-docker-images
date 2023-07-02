ARG IMAGE_REF=amidostacks/runner-pwsh
FROM ubuntu:22.04 as base

# ARG orgname=amidostacks
ARG INSPEC_VERSION=5.22.3

RUN apt-get update && apt-get install curl -y

# -- Inspec for infrastructure testing
RUN curl "https://omnitruck.chef.io/install.sh" -o "install.sh" && \
    chmod +x ./install.sh && \
    ./install.sh -P inspec -v ${INSPEC_VERSION} && \
    rm install.sh

# The ARG is repeated here because it needs to be refreshed from the initial setting
# The behaviour of FROM and ARG is explained here - https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG IMAGE_REF
FROM $IMAGE_REF

ARG APK_GLIBC_VERSION=2.35-r1
ARG APK_GLIBC_FILE="glibc-${APK_GLIBC_VERSION}.apk"
ARG APK_GLIBC_BIN_FILE="glibc-bin-${APK_GLIBC_VERSION}.apk"
ARG APK_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${APK_GLIBC_VERSION}"

# Install necessary packages
RUN apk --no-cache add \
    ca-certificates \
    libstdc++ \
    libc-dev

# Get and install Glibc
RUN curl -o /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
    && wget "${APK_GLIBC_BASE_URL}/${APK_GLIBC_FILE}"       \
    && apk --force-overwrite --no-cache add "${APK_GLIBC_FILE}"               \
    && wget "${APK_GLIBC_BASE_URL}/${APK_GLIBC_BIN_FILE}"   \
    && apk --no-cache add "${APK_GLIBC_BIN_FILE}"           \
    && rm glibc-*

ENV PATH="${PATH}:/opt/inspec/bin"

# Copy the inspec directory from the base image
COPY --from=base /opt/inspec /opt/inspec




