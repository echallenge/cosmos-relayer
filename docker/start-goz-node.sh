#!/usr/bin/env bash

gaiad init --chain-id gameofzoneshub-2 fetchgoznode2

sed -i 's#tcp://127.0.0.1:26657#tcp://0.0.0.0:26657#g' ~/.gaiad/config/config.toml
sed -i 's#persistent_peers = ""#persistent_peers = "6ed008bf3a2ad341d84391bf47ea46e75a87e35e@35.233.155.199:26656,7cb9cbba21fdc3b004f098c116e5e2c2ac77ddfb@34.83.218.4:26656"#g' ~/.gaiad/config/config.toml
wget https://raw.githubusercontent.com/cosmosdevs/GameOfZones/master/goz-genesis.json && \
mv goz-genesis.json ~/.gaiad/config/genesis.json

gaiad start