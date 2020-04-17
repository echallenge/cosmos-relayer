#!/usr/bin/env bash
rly config init

for ID in 0 1
do
export DENOM="token${ID}"
export CHAINID="ibc${ID}"
export DOMAIN="ibc${ID}"
export RLYKEY="faucet${ID}"

echo "{\"key\":\"$RLYKEY\",\"chain-id\":\"$CHAINID\",\"rpc-addr\":\"http://$DOMAIN:26657\",\"account-prefix\":\"cosmos\",\"gas\":200000,\"gas-prices\":\"0.025$DENOM\",\"default-denom\":\"$DENOM\",\"trusting-period\":\"330h\"}" > $CHAINID.json
rly chains add -f $CHAINID.json
done


rly keys add ibc0 testkey
rly keys add ibc1 testkey

rly ch edit ibc0 key testkey
rly ch edit ibc1 key testkey

rly lite init ibc0 -f
rly lite init ibc1 -f

rly tst request ibc0 testkey
rly tst request ibc1 testkey

rly q bal ibc0
rly q bal ibc1

rly pth gen ibc0 ibc1 demo-path

rly tx full-path demo-path

# rly tx transfer ibc0 ibc1 100token0 true $(rly ch addr ibc1) 

while true
do
    echo "sleeping forever"
    sleep 3600
done 