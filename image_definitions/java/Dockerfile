ARG IMAGE_REF=amidostacks/runner-pwsh

FROM $IMAGE_REF

ARG JAVA_VERSION=17.0.9-r1
ARG MAVEN_VERSION=3.8.8

# Install Zulu Java
# Ref: https://docs.azul.com/core/zulu-openjdk/install/alpine-linux
RUN curl https://cdn.azul.com/public_keys/alpine-signing@azul.com-5d5dc44c.rsa.pub -o /etc/apk/keys/alpine-signing@azul.com-5d5dc44c.rsa.pub \
 && echo "https://repos.azul.com/zulu/alpine" | tee -a /etc/apk/repositories \
 && apk update \
 && apk add --no-cache zulu17-jdk=${JAVA_VERSION}

# Install Maven
RUN curl "https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.zip" -o /tmp/maven.zip && \
    unzip /tmp/maven.zip -d /usr/local && \
    rm /tmp/maven.zip

ENV JAVA_HOME=/usr/lib/jvm/default-jvm/jre


