ARG orgname=amidostacks

FROM ${orgname}/runner-pwsh

# Install the data extension for the Az command
RUN /azure-cli/bin/python -m azure.cli extension add --name datafactory
