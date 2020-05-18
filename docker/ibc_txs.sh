#!/usr/bin/env bash
rly config init

echo '{"key":"faucet","chain-id":"fetchBeacon-1b","rpc-addr":"http://fetch-goz.fetch.ai:26657","account-prefix":"cosmos","gas":200000,"gas-prices":"0.025ufet","default-denom":"ufet","trusting-period":"9m"}' > root/chain0.json
echo '{"key": "faucet","chain-id": "gameofzoneshub-1b","rpc-addr": "http://35.190.35.11:80","account-prefix": "cosmos","gas": 200000,"gas-prices": "0.025doubloons","default-denom": "doubloons","trusting-period": "9m"}' > /root/chain1.json


rly chains add -f /root/chain0.json
rly chains add -f /root/chain1.json
echo "Chain configs added"
sleep 5

rly lite init fetchBeacon-1b -f
rly lite init gameofzoneshub-1b -f
echo "Lite clients initiated"
sleep 5


rly keys restore fetchBeacon-1b accname "deer culture observe tent bitter depend moment train wasp approve erase grit seek cake bag truck program sea hub spin avoid crack rib skull"
rly keys restore gameofzoneshub-1b accname "deer culture observe tent bitter depend moment train wasp approve erase grit seek cake bag truck program sea hub spin avoid crack rib skull"
echo "Account created for both chains"
sleep 5

rly ch edit fetchBeacon-1b key accname
rly ch edit gameofzoneshub-1b key accname
echo "Selected accname account as default for both chains"
sleep 5

rly tst request fetchBeacon-1b accname
# rly tst request gameofzoneshub-1b accname
# echo "Requested funds from both chains.sh"
# sleep 5

rly pth gen fetchBeacon-1b transfer gameofzoneshub-1b transfer demopath -f



while true
do
	
	rly transact clients demopath
	rly transact connection demopath
	rly transact channel demopath
	rly pth show demopath
	echo "TX link verified"
	sleep 5
	echo "Doing IBC TX"
	rly tx transfer fetchBeacon-1b gameofzoneshub-1b "5ufet" true $(rly ch addr gameofzoneshub-1b)
	rly q bal fetchBeacon-1b
	rly q bal gameofzoneshub-1b
	echo "Sleeping"
    sleep 640
done