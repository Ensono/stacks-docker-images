ARG orgname=amidostacks

FROM ${orgname}/runner-pwsh

# Install python3 and pip
RUN apk add --nocache --update python3 py3-pip

# Install the necessary python modules
COPY ./requirements.txt .
RUN pip3 install -r ./requirements.txt
