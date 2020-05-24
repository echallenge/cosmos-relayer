#!/usr/bin/env bash

function sendibctx {
	rly tx transfer fetchBeacon-2 gameofzoneshub-2a "1ufet" true $(rly ch addr gameofzoneshub-2a)
	rly q bal fetchBeacon-2
	rly q bal gameofzoneshub-2a
	echo "Sent IBC $1"
}

function sendreverseibctx {
	rly tx transfer gameofzoneshub-2a fetchBeacon-2 "700000000000ufet" false $(rly ch addr fetchBeacon-2)
	rly q bal fetchBeacon-2
	rly q bal gameofzoneshub-2a
	echo "Sent reverse IBC"
}

rly config init

echo '{"key":"faucet","chain-id":"fetchBeacon-2","rpc-addr":"http://fetch-goz.fetch.ai:26657","account-prefix":"cosmos","gas":200000,"gas-prices":"0.025ufet","default-denom":"ufet","trusting-period":"168h"}' > root/fetch.json
echo '{"key": "faucet","chain-id": "gameofzoneshub-2a","rpc-addr": "http://goz-node:26657","account-prefix": "cosmos","gas": 200000,"gas-prices": "0.025doubloons","default-denom": "doubloons","trusting-period": "168h"}' > /root/hub.json


rly chains add -f /root/fetch.json
rly chains add -f /root/hub.json
echo "Chain configs added"
sleep 5

rly lite init fetchBeacon-2 -f
rly lite init gameofzoneshub-2a -f
echo "Lite clients initiated"
sleep 5


rly keys restore fetchBeacon-2 accname "deer culture observe tent bitter depend moment train wasp approve erase grit seek cake bag truck program sea hub spin avoid crack rib skull"
rly keys restore gameofzoneshub-2a accname "deer culture observe tent bitter depend moment train wasp approve erase grit seek cake bag truck program sea hub spin avoid crack rib skull"
echo "Account created for both chains"
sleep 5

rly ch edit fetchBeacon-2 key accname
rly ch edit gameofzoneshub-2a key accname
echo "Selected accname account as default for both chains"
sleep 5

# rly tst request fetchBeacon-2 accname
# rly tst request gameofzoneshub-1b accname
# echo "Requested funds from both chains.sh"
# sleep 5

echo "Sleep until the morning"
sleep 38400

rly pth gen fetchBeacon-2 transfer gameofzoneshub-2a transfer demopath -f
rly transact clients demopath
rly transact connection demopath
rly transact channel demopath
rly pth show demopath
echo "TX link verified"

totaltxs=0
while true
do
	counter=1
	while [ "$counter" -le "20" ]
	do
		sendibctx $counter
		counter=$((counter + 1))
		totaltxs=$((totaltxs + 1))
	done

	if [ "$((totaltxs % 710000000000))" -eq "0" ]
	then
		sendreverseibctx
	fi
	echo "Total TXs $totaltxs"
    sleep 5
done