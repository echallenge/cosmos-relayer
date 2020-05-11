#!/usr/bin/env bash

IP=$(ip address show eth0 | awk '$1 == "inet" { print $2 }' | cut -d/ -f1)

gaiad init --chain-id gameofzoneshub-2 fetchgoznode2

# sed -i 's#persistent_peers = ""#persistent_peers = "6ed008bf3a2ad341d84391bf47ea46e75a87e35e@35.233.155.199:26656,7cb9cbba21fdc3b004f098c116e5e2c2ac77ddfb@34.83.218.4:26656"#g' ~/.gaiad/config/config.toml
wget https://raw.githubusercontent.com/cosmosdevs/GameOfZones/master/goz-genesis.json && \
mv goz-genesis.json ~/.gaiad/config/genesis.json

gaiad start --p2p.laddr tcp://$IP:26656 --rpc.laddr tcp://0.0.0.0:2665 --p2p.seeds="d95a9f97e31f36d0a467e6855c71f5e5b8eccf65@34.83.90.172:26656"