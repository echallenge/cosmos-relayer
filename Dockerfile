FROM golang:buster

# Set up dependencies
ENV PACKAGES curl make git libc-dev bash gcc python

# Set working directory for the build
WORKDIR /go/src/github.com/cosmos/gaia

# Add source files
RUN git clone https://github.com/cosmos/gaia.git . && \
    git checkout ibc-alpha

# Install minimum necessary dependencies, build Cosmos SDK, remove packages
RUN apt update && \
	apt install -y $PACKAGES && \
    make tools && \
    make build

RUN cp /go/src/github.com/cosmos/gaia/build/gaiad /usr/bin/gaiad
RUN cp /go/src/github.com/cosmos/gaia/build/gaiacli /usr/bin/gaiacli

ADD docker/start-chain.sh /usr/bin/start-chain.sh

# Set working directory for the build
WORKDIR /go/src/github.com/cosmos/relayer

ADD . .

RUN make build

# Copy over binaries from the relayer-builder
RUN cp /go/src/github.com/cosmos/relayer/build/rly /usr/bin/rly

ADD docker/sleep_forever.sh /usr/bin/sleep_forever.sh

WORKDIR /

EXPOSE 26657
EXPOSE 8000 
