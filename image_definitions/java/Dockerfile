ARG NODE_VERSION=14
ARG IMAGE_REF=amidostacks/runner-pwsh

FROM node:${NODE_VERSION}-alpine as node

FROM $IMAGE_REF

ARG JAVA_VERSION=17.0.9-r1
ARG MAVEN_VERSION=3.8.8

# Install Zulu Java
# Ref: https://docs.azul.com/core/zulu-openjdk/install/alpine-linux
RUN curl https://cdn.azul.com/public_keys/alpine-signing@azul.com-5d5dc44c.rsa.pub -o /etc/apk/keys/alpine-signing@azul.com-5d5dc44c.rsa.pub \
 && echo "https://repos.azul.com/zulu/alpine" | tee -a /etc/apk/repositories \
 && apk update \
 && apk add --no-cache zulu17-jdk=${JAVA_VERSION} bash sudo shadow gnupg

# Install Maven
RUN curl "https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.zip" -o /tmp/maven.zip && \
    unzip /tmp/maven.zip -d /usr/local && \
    rm /tmp/maven.zip

ENV JAVA_HOME=/usr/lib/jvm/default-jvm/jre

# Copy node into the image
COPY --from=node /usr/lib /usr/lib
COPY --from=node /usr/local/lib /usr/local/lib
COPY --from=node /usr/local/include /usr/local/include
COPY --from=node /usr/local/bin /usr/local/bin

# Add a label to state where node is
LABEL "com.azure.dev.pipelines.agent.handler.node.path"="/usr/local/bin/node"

CMD ["node"]
