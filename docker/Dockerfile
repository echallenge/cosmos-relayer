FROM golang:buster AS builder

# Set up dependencies
# ENV PACKAGES curl make git libc-dev bash gcc python

# Set working directory for the build
WORKDIR /go/src/github.com/cosmos/gaia

# Add source files
RUN git clone https://github.com/cosmos/gaia.git . && \
    git checkout 50be36de941b9410a4b06ec9ce4288b1529c4bd4

# Install minimum necessary dependencies, build Cosmos SDK, remove packages
# RUN apt update && \
# 	apt install -y $PACKAGES && \
#     make tools && \
#     make build
RUN make build

RUN cp /go/src/github.com/cosmos/gaia/build/gaiad /usr/bin/gaiad
RUN cp /go/src/github.com/cosmos/gaia/build/gaiacli /usr/bin/gaiacli

# Set working directory for the build
WORKDIR /go/src/github.com/cosmos/relayer


RUN git clone https://github.com/iqlusioninc/relayer.git . && \
    git checkout 781026cf46c6d144ab7fcd02d92817cc3d524903

RUN make build

# Copy over binaries from the relayer-builder
RUN cp /go/src/github.com/cosmos/relayer/build/rly /usr/bin/rly

###################################################
FROM ubuntu:focal

COPY --from=builder /usr/bin/rly /usr/bin/rly
COPY --from=builder /usr/bin/gaiad /usr/bin/gaiad
COPY --from=builder /usr/bin/gaiacli /usr/bin/gaiacli

ADD start-chain.sh /usr/bin/start-chain.sh
ADD sleep_forever.sh /usr/bin/sleep_forever.sh
ADD ibc_txs.sh /usr/bin/ibc_txs.sh

WORKDIR /


EXPOSE 26657
EXPOSE 8000 
