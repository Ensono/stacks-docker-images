# This image builds on the base image and installs Python
# for linting YAML

FROM amidostacks/runner-pwsh

# Install python3 and pip3
RUN apt-get update && \
    apt-get install -y python3 \
    python3-pip

# Install the necessary python modules
COPY ./requirements.txt .
RUN pip3 install -r ./requirements.txt
