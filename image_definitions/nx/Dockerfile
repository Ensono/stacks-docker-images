# This image builds on the base image and installs Nx
# for building frontend applications

FROM amidostacks/runner-pwsh:0.3.151-stable

# Define the version of Node to install
ARG NODEJS_VERSION=19
ARG NX_VERSION=15.3.0

# Install the necessary foundation apps
RUN apt update && \
    apt install -y curl 

# Download and install Nodejs from Nodesource
RUN curl -fsSL https://deb.nodesource.com/setup_${NODEJS_VERSION}.x | bash - && \
    apt install nodejs

# Install Nx
RUN npm install -g nx@${NX_VERSION}

# Tidy up the image
RUN apt-get -y remove curl && \
    apt-get -y autoremove