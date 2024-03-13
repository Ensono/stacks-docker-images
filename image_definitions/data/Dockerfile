ARG IMAGE_REF=amidostacks/runner-pwsh
FROM $IMAGE_REF

# Install the data extension for the Az command
# Add latest version of python, databricks CLI, precommit and tomli, and other python dependencies
RUN /azure-cli/bin/python -m azure.cli extension add --name datafactory \
    && apk del py3-pip \
    && apk add --no-cache --update \
        python3 \
        gcc \
        musl-dev \
        linux-headers \
        python3-dev \
    && python -m ensurepip --upgrade \
    && ln -s $(which pip3) /usr/bin/pip \
    && pip install wheel \
    && pip install --no-cache-dir \
        pytest \
        pylint \
        pylint-exit \
        pytest-azurepipelines \
        pytest-cov \
        databricks-cli \
        pre-commit \
        tomli \
        poetry
