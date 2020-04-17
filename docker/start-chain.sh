#!/usr/bin/env bash

export DENOM="token${ID}"
export CHAINID="ibc${ID}"
export DOMAIN="ibc${ID}"
export RLYKEY="faucet${ID}"

# Move on to configuring gaia
gaiad init --chain-id $CHAINID $CHAINID
# NOTE: ensure that the gaia rpc is open to all connections
sed -i 's#tcp://127.0.0.1:26657#tcp://0.0.0.0:26657#g' ~/.gaiad/config/config.toml
sed -i "s/stake/$DENOM/g" ~/.gaiad/config/genesis.json
sed -i 's/pruning = "syncable"/pruning = "nothing"/g' ~/.gaiad/config/app.toml

gaiacli config keyring-backend test
# Generate genesis account
gaiacli keys add validator
# Generate faucet account
rly config init
echo "{\"key\":\"$RLYKEY\",\"chain-id\":\"$CHAINID\",\"rpc-addr\":\"http://$DOMAIN:26657\",\"account-prefix\":\"cosmos\",\"gas\":200000,\"gas-prices\":\"0.025$DENOM\",\"default-denom\":\"$DENOM\",\"trusting-period\":\"330h\"}" > $CHAINID.json
rly chains add -f $CHAINID.json
rly keys restore $CHAINID $RLYKEY "${FAUCETMNEMONIC}"

gaiad add-genesis-account $(gaiacli keys show validator -a) 100000000000$DENOM,100000000000sharedtoken --keyring-backend test
gaiad add-genesis-account $(rly chains addr $CHAINID) 100000000000$DENOM,100000000000sharedtoken --keyring-backend test
gaiad gentx --name validator --amount 10000000000$DENOM --keyring-backend test
gaiad collect-gentxs

sleep 30 && rly testnets faucet $CHAINID $RLYKEY 20000000000$DENOM &

gaiad start