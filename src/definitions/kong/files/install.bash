
# Get the architecture of the container
. /usr/local/bin/platform.bash

# Install Deck
curl -L "https://github.com/kong/deck/releases/download/v${DECK_VERSION}/deck_${DECK_VERSION}_linux_${BIN_ARCH}.tar.gz" -o /tmp/deck.tar.gz
cd /tmp
tar zxf /tmp/deck.tar.gz -C /usr/bin deck
chmod +x /usr/bin/deck
rm /tmp/deck.tar.gz

# Install PortalCLI
curl -L "https://github.com/AButler/kong-portal-cli/releases/download/v${PORTAL_CLI_VERSION}/portal-cli-linux-${MUSL_ARCH}.tar.gz" -o /tmp/portal-cli.tar.gz
tar zxf /tmp/portal-cli.tar.gz -C /usr/bin portal-cli
chmod +x /usr/bin/portal-cli
rm /tmp/portal-cli.tar.gz
