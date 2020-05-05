#!/usr/bin/env bash
rly config init

for ID in 0 1
do
export DENOMUSE="${DENOM}${ID}"
export CHAINIDUSE="${CHAINID}${ID}"
export DOMAINUSE="${DOMAIN}${ID}"
export RLYKEYUSE="${RLYKEY}${ID}"

echo "{\"key\":\"$RLYKEYUSE\",\"chain-id\":\"$CHAINIDUSE\",\"rpc-addr\":\"http://$DOMAINUSE:26657\",\"account-prefix\":\"cosmos\",\"gas\":200000,\"gas-prices\":\"0.025$DENOMUSE\",\"default-denom\":\"$DENOMUSE\",\"trusting-period\":\"330h\"}" > $CHAINIDUSE.json
rly chains add -f $CHAINIDUSE.json
done

sleep 50

for i in 0 1
do
	rly lite init fetchBeacon${i} -f
	rly keys add fetchBeacon${i} testkey
	rly ch edit fetchBeacon${i} key testkey
	rly tst request fetchBeacon${i} testkey
	rly q bal fetchBeacon${i}
done

rly pth gen fetchBeacon0 transfer fetchBeacon1 transfer demopath

rly tx full-path demopath
echo "Channel initiated"

while true
do
	echo "Performing migration from fetchBeacon0 to fetchBeacon1"
	rly tx transfer fetchBeacon0 fetchBeacon1 "10${DENOM}0" true $(rly ch addr fetchBeacon1)
	rly q bal fetchBeacon0
	rly q bal fetchBeacon1
    sleep 1800
done 