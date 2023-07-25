ARG IMAGE_REF=amidostacks/runner-pwsh
FROM $IMAGE_REF

# Install the data extension for the Az command
RUN /azure-cli/bin/python -m azure.cli extension add --name datafactory

# Install the databricks CLI
RUN pip install databricks-cli

# Remove old python and pip versions
RUN  apk del py-pip \  
     && apk del  python3-dev py3-pip \
     && rm -rf ~/.cache/pip \ 
     && apk del  python3

# Add new updated repositry 
RUN echo "https://dl-cdn.alpinelinux.org/alpine/v3.18/main" > /etc/apk/repositories 
RUN echo "https://dl-cdn.alpinelinux.org/alpine/v3.18/community" >> /etc/apk/repositories 
RUN apk update

# Add latest version of python  and poetry
RUN apk add --update python3 py3-pip  python3-dev
RUN pip install pytest pylint pylint-exit pytest-azurepipelines pytest-cov poetry