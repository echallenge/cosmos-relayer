#!/usr/bin/env bash
rly config init

echo '{"chain_id":"fetchBeacon","node_addr":"tcp://fetch-goz.fetch.ai:26657"}' > root/chain0.json
echo '{"key": "faucet","chain-id": "gameofzoneshub-2","rpc-addr": "http://35.190.35.11:80","account-prefix": "cosmos","gas": 200000,"gas-prices": "0.025doubloons","default-denom": "doubloons","trusting-period": "90m"}' > /root/chain1.json


rly chains add -f /root/chain0.json
rly chains add -f /root/chain1.json
echo "Chain configs added"
sleep 5

rly lite init fetchBeacon -f
rly lite init gameofzoneshub-1a -f
echo "Lite clients initiated"
sleep 5


rly keys restore fetchBeacon accname "deer culture observe tent bitter depend moment train wasp approve erase grit seek cake bag truck program sea hub spin avoid crack rib skull"
rly keys restore gameofzoneshub-1a accname "deer culture observe tent bitter depend moment train wasp approve erase grit seek cake bag truck program sea hub spin avoid crack rib skull"
echo "Account created for both chains"
sleep 5

rly ch edit fetchBeacon key accname
rly ch edit gameofzoneshub-1a key accname
echo "Selected accname account as default for both chains"
sleep 5

# rly tst request fetchBeacon accname
# rly tst request gameofzoneshub-1a accname
# echo "Requested funds from both chains.sh"
sleep 5

rly pth gen fetchBeacon transfer gameofzoneshub-1a transfer demopath -f

s=fetchBeacon && \
d=gameofzoneshub-1a && \
p=demopath && \
rly transact clients $p --debug &> out1.log ; wait && \
rly transact connection $p --debug &> out2.log ; wait && \
rly transact channel $p --debug &> out3.log ; wait && \
rly pth show $p
rly tx full-path demopath
echo "TX link verified"

while true
do
	echo "Performing migration from fetchBeacon to stackmybits"
	rly tx transfer fetchBeacon gameofzoneshub-1a "5sharedtoken" true $(rly ch addr gameofzoneshub-1a)
	rly q bal fetchBeacon
	rly q bal gameofzoneshub-1a
    sleep 60
done 