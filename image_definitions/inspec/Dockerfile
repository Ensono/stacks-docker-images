ARG IMAGE_REF=amidostacks/runner-pwsh:latest
FROM $IMAGE_REF

# Set the version of Inspec to install
ARG INSPEC_VERSION=5.22.3

# Update apk and install ruby
RUN apk update && \
    apk add gcompat \
            ruby \
            build-base \
            ruby-dev

# Install the specified version of inspec
RUN gem install etc && \
    gem install bigdecimal && \
    gem install io-console
    
RUN gem install inspec-bin -v ${INSPEC_VERSION}

# Remove packages that are no longer needed
RUN apk del build-base \
            ruby-dev

