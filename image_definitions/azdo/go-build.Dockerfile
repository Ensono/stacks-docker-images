FROM node:16-alpine

# ADD TFS dependencies
RUN apk add --no-cache --virtual .pipeline-deps readline linux-pam \
  && apk add bash sudo shadow gcompat curl git \
  && apk del .pipeline-deps
RUN apk add zip unzip make

LABEL "com.azure.dev.pipelines.agent.handler.node.path"="/usr/local/bin/node"

# Go deps
RUN apk add 'go~1.18' libc6-compat

CMD [ "node" ]

# TFS says not to add entrypoint
# however it seems to only work with
# this entrypoint set
ENTRYPOINT [ "/usr/bin/env" ]