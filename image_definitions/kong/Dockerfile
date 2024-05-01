ARG IMAGE_REF=amidostacks/runner-pwsh

FROM $IMAGE_REF

ARG DECK_VERSION=1.37.0
ARG PORTAL_CLI_VERSION=2.0.0

# -- Deck
RUN export ARCH="$(uname -m)" \
    && if [[ ${ARCH} == "x86_64" ]]; then export ARCH="amd64"; elif [[ ${ARCH} == "aarch64" ]]; then export ARCH="arm64"; fi \
    && curl -L "https://github.com/kong/deck/releases/download/v${DECK_VERSION}/deck_${DECK_VERSION}_linux_${ARCH}.tar.gz" -o /tmp/deck.tar.gz \
    && tar zxf /tmp/deck.tar.gz -C /usr/bin deck \
    && chmod +x /usr/bin/deck

# -- Portal CLI
RUN export ARCH="$(uname -m)" \
    export MUSL="$(ldd /bin/ls | grep 'musl' | head -1 | cut -d ' ' -f1)" \
    && if [[ ${ARCH} == "x86_64" ]]; then if [[ -n ${MUSL} ]]; then export ARCH="musl-x64"; else export ARCH="x64"; fi; elif [[ ${ARCH} == "aarch64" ]]; then export ARCH="arm64"; fi \
    && curl -L "https://github.com/AButler/kong-portal-cli/releases/download/v${PORTAL_CLI_VERSION}/portal-cli-linux-${ARCH}.tar.gz" -o /tmp/portal-cli.tar.gz \
    && tar zxf /tmp/portal-cli.tar.gz -C /usr/bin portal-cli \
    && chmod +x /usr/bin/portal-cli
