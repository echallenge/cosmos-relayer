#!/usr/bin/env bash

IP=$(ip address show eth0 | awk '$1 == "inet" { print $2 }' | cut -d/ -f1)

gaiad init --chain-id gameofzoneshub-2 fetchgoznode2

mv /genesis.json ~/.gaiad/config/genesis.json

gaiad start --p2p.laddr tcp://$IP:26656 --rpc.laddr tcp://0.0.0.0:26657 --p2p.seeds="d95a9f97e31f36d0a467e6855c71f5e5b8eccf65@34.83.90.172:26656"