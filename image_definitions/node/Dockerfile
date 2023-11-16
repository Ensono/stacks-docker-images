
ARG NODE_VERSION=16.20.2
ARG IMAGE_REF=amidostacks/runner-pwsh

FROM node:${NODE_VERSION}-alpine AS node

FROM $IMAGE_REF

COPY --from=node /usr/lib /usr/lib
COPY --from=node /usr/local/lib /usr/local/lib
COPY --from=node /usr/local/include /usr/local/include
COPY --from=node /usr/local/bin /usr/local/bin

RUN apk update \
    && apk add bash