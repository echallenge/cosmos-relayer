# #!/usr/bin/env bash
rly config init

echo '{"key":"faucet","chain-id":"fetchBeacon","rpc-addr":"http://fetch-goz.fetch.ai:26657","account-prefix":"cosmos","gas":200000,"gas-prices":"0.025sharedtoken","default-denom":"sharedtoken","trusting-period":"330h"}' > root/chain0.json
echo '{"key": "faucet","chain-id": "gameofzoneshub-1a","rpc-addr": "http://35.233.155.199:26657","account-prefix": "cosmos","gas": 200000,"gas-prices": "0.025doubloons","default-denom": "doubloons","trusting-period": "90m"}' > /root/chain1.json


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

rly tst request fetchBeacon accname
# rly tst request gameofzoneshub-1a accname
# echo "Requested funds from both chains.sh"
sleep 5

rly pth gen fetchBeacon transfer gameofzoneshub-1a transfer demopath
rly tx full-path demopath
echo "TX link verified"

while true
do
	echo "Performing migration from fetchBeacon to stackmybits"
	rly tx transfer fetchBeacon gameofzoneshub-1a "5sharedtoken" true $(rly ch addr gameofzoneshub-1a)
	rly q bal fetchBeacon
	rly q bal stackmybits
    sleep 1800
done 