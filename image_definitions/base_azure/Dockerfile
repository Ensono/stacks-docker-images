# Start with a powershell image and copy necessary tools into it
ARG ALPINE_VERSION=3.17
ARG POWERSHELL_VERSION=7.3-alpine-${ALPINE_VERSION}

FROM independent-runner-foundation as foundation

# Install required tools into a PowerShell Alpine image
FROM mcr.microsoft.com/powershell:${POWERSHELL_VERSION}

# Install python for the AZ cli
RUN echo "https://dl-cdn.alpinelinux.org/alpine/v3.17/main" > /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/v3.17/community" >> /etc/apk/repositories && \
    apk update && \
    apk add --no-cache --update \
        python3

# Copy over necessary tools
COPY --from=foundation /usr/local/kubectl /usr/local/kubectl
COPY --from=foundation /usr/local/helm /usr/local/helm
COPY --from=foundation /usr/local/terraform /usr/local/terraform
COPY --from=foundation /usr/local/taskctl /usr/local/taskctl
COPY --from=foundation /usr/local/kluctl /usr/local/kluctl
COPY --from=foundation /usr/local/kustomize /usr/local/kustomize

# Create the necessary symlinks so the apps are found in the path
RUN ln -s /usr/local/kubectl/bin/kubectl /usr/bin/kubectl && \
    ln -s /usr/local/helm/bin/helm /usr/bin/helm && \
    ln -s /usr/local/terraform/bin/terraform /usr/bin/terraform && \
    ln -s /usr/local/taskctl/bin/taskctl /usr/bin/taskctl && \
    ln -s /usr/local/kluctl/bin/kluctl /usr/bin/kluctl && \
    ln -s /usr/local/kustomize/bin/kustomize /usr/bin/kustomize

# Copy over PowerShell modules
COPY --from=foundation /usr/local/share/powershell/Modules /usr/local/share/powershell/Modules
COPY --from=foundation /modules /modules

# Copy the AZ CLI
COPY --from=foundation /usr/local/azcli /usr/local/azcli
RUN ln -s /usr/local/azcli/bin/az /usr/bin/az

# Fix the symlink for python
RUN rm /usr/local/azcli/venv/bin/python && \
    ln -s `which python` /usr/local/azcli/venv/bin/python

