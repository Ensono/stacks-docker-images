ARG IMAGE_REF=amidostacks/runner-pwsh

FROM $IMAGE_REF

ARG DECK_VERSION=1.30.0
ARG YQ_VERSION=4.40.7

# -- Deck
RUN export ARCH="$(uname -m)" \
    && if [[ ${ARCH} == "x86_64" ]]; then export ARCH="amd64"; elif [[ ${ARCH} == "aarch64" ]]; then export ARCH="arm64"; fi \
    && curl -L "https://github.com/kong/deck/releases/download/v${DECK_VERSION}/deck_${DECK_VERSION}_linux_${ARCH}.tar.gz" -o /tmp/deck.tar.gz \
    && tar zxf /tmp/deck.tar.gz -C /usr/bin deck \
    && chmod +x /usr/bin/deck

# -- YQ
RUN export ARCH="$(uname -m)" \
    && if [[ ${ARCH} == "x86_64" ]]; then export ARCH="amd64"; elif [[ ${ARCH} == "aarch64" ]]; then export ARCH="arm64"; fi \
    && curl -L "https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_${ARCH}.tar.gz" -o /tmp/yq.tar.gz \
    && tar zxf /tmp/yq.tar.gz \
    && mv yq_linux_${ARCH} /usr/bin/yq \
    && chmod +x /usr/bin/yq