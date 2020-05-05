# #!/usr/bin/env bash
apt update && apt install -y wget

wget https://gist.githubusercontent.com/harsh-98/befc5e2076807aab102710b06db20567/raw/19b09779ee892d942c7b8a131bec930777d70d8b/chains.json

# rly config init

# echo '{"key":"faucetkey","chain-id":"fetchBeacon","rpc-addr":"http://fetch-goz.fetch.ai:26657","account-prefix":"cosmos","gas":200000,"gas-prices":"0.025ufet","default-denom":"ufet","trusting-period":"330h"}' > root/chain0.json
# echo '{"key":"faucet","chain-id":"stackmybits","rpc-addr":"http://dockme.nl:26657","account-prefix":"cosmos","gas":200000,"gas-prices":"0.025bits","default-denom":"bits","trusting-period":"330h"}' > /root/chain1.json


# rly chains add -f /root/chain0.json
# rly chains add -f /root/chain1.json
# echo "Chain configs added"
# sleep 5

# rly lite init fetchBeacon -f
# rly lite init stackmybits -f

# echo "Lite clients initiated"
# sleep 5


# rly keys restore fetchBeacon accname "deer culture observe tent bitter depend moment train wasp approve erase grit seek cake bag truck program sea hub spin avoid crack rib skull"
# rly keys restore stackmybits accname "deer culture observe tent bitter depend moment train wasp approve erase grit seek cake bag truck program sea hub spin avoid crack rib skull"
# echo "Account created for both chains"
# sleep 5

# rly ch edit fetchBeacon key accname
# rly ch edit stackmybits key accname
# echo "Selected accname account as default for both chains"
# sleep 5

# rly tst request fetchBeacon accname
# rly tst request stackmybits accname
# echo "Requested funds from both chains.sh"
# sleep 5

# rly pth gen fetchBeacon transfer stackmybits transfer demopath
# rly tx full-path demopath
# echo "TX link verified"

while true
do
# 	echo "Performing migration from fetchBeacon to stackmybits"
# 	rly tx transfer fetchBeacon stackmybits "5ufet" true $(rly ch addr stackmybits)
# 	rly q bal fetchBeacon
# 	rly q bal stackmybits
#     sleep 1800
done 