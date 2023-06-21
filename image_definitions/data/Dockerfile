ARG IMAGE_REF=amidostacks/runner-pwsh
FROM $IMAGE_REF

# Install the data extension for the Az command
RUN /azure-cli/bin/python -m azure.cli extension add --name datafactory
