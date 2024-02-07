ARG IMAGE_REF=amidostacks/runner-pwsh

FROM $IMAGE_REF

ARG DECK_VERSION=1.30.0

# -- Deck
RUN export ARCH="$(uname -m)" \
    && if [[ ${ARCH} == "x86_64" ]]; then export ARCH="amd64"; elif [[ ${ARCH} == "aarch64" ]]; then export ARCH="arm64"; fi \
    && curl -L "https://github.com/kong/deck/releases/download/v${DECK_VERSION}/deck_${DECK_VERSION}_linux_${ARCH}.tar.gz" -o /tmp/deck.tar.gz \
    && tar zxf /tmp/deck.tar.gz -C /usr/bin deck \
    && chmod +x /usr/bin/deck
