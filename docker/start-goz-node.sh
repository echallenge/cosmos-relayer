#!/usr/bin/env bash

gaiad init fetchGozNode

curl http://35.190.35.11/genesis\? | jq .result.genesis > ~/.gaiad/config/genesis.json

gaiad start --p2p.laddr tcp://127.0.0.1:26656 --rpc.laddr tcp://127.0.0.1:26657 --p2p.seeds="d95a9f97e31f36d0a467e6855c71f5e5b8eccf65@34.83.90.172:26656"
