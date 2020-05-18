#!/usr/bin/env bash
rly config init

echo '{"key":"faucet","chain-id":"fetchBeacon-1b","rpc-addr":"http://fetch-goz.fetch.ai:26657","account-prefix":"cosmos","gas":200000,"gas-prices":"0.025sharedtoken","default-denom":"sharedtoken","trusting-period":"11m"}' > root/chain0.json
echo '{"key": "faucet","chain-id": "gameofzoneshub-1b","rpc-addr": "http://goz-node:26657","account-prefix": "cosmos","gas": 200000,"gas-prices": "0.025doubloons","default-denom": "doubloons","trusting-period": "11m"}' > /root/chain1.json


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
rly tst request gameofzoneshub-1a accname
echo "Requested funds from both chains.sh"
sleep 5

rly pth gen fetchBeacon-1b transfer gameofzoneshub-1b transfer demopath -f

# s=fetchBeacon-1b && \
# d=gameofzoneshub-1b && \
# p=demopath && \
# rly transact clients $p --debug &> out1.log ; wait && \
# rly transact connection $p --debug &> out2.log ; wait && \
# rly transact channel $p --debug &> out3.log ; wait && \
# rly pth show $p
rly tx full-path demopath
echo "TX link verified"

while true
do
	echo "Sleeping"
	# rly tx transfer fetchBeacon-1b gameofzoneshub-1b "5ufet" true $(rly ch addr gameofzoneshub-1b)
	# rly q bal fetchBeacon-1b
	# rly q bal gameofzoneshub-1b
    sleep 3600
done