Before running the docker-compose contained in this folder run `docker build -t gaia-ibc .`.

If you run `docker-compose up` two chains are created with two faucets.
Then the client container creates two accounts (1 for each chain), and requests funds through the faucet.

After that, the client container initiates one IBC tx from ibc0 --> ibc1 every two minutes.