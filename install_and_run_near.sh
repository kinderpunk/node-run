#!/usr/bin/bash
. <(wget -qO- https://raw.githubusercontent.com/Penton7/node-run/main/logo.sh)

sudo apt install -y git binutils-dev libcurl4-openssl-dev zlib1g-dev libdw-dev libiberty-dev cmake gcc g++ python docker.io protobuf-compiler libssl-dev pkg-config llvm cargo
sudo apt install clang build-essential make
sudo apt install curl jq
curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install nodejs
PATH="$PATH"

sudo npm install -g near-cli

export NEAR_ENV=shardnet
echo 'export NEAR_ENV=shardnet' >> ~/.bashrc

sudo apt install python3-pip

USER_BASE_BIN=$(python3 -m site --user-base)/bin
export PATH="$USER_BASE_BIN:$PATH"

cd $HOME

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

git clone https://github.com/near/nearcore
cd nearcore
git fetch
git checkout c1b047b8187accbf6bd16539feb7bb60185bdc38

cargo build -p neard --release --features shardnet
./target/release/neard --home ~/.near init --chain-id shardnet --download-genesis

rm ~/.near/config.json
wget -O ~/.near/config.json https://s3-us-west-1.amazonaws.com/build.nearprotocol.com/nearcore-deploy/shardnet/config.json

sudo tee <<EOF >/dev/null /etc/systemd/system/neard.service
[Unit]
Description=NEARd Daemon Service

[Service]
Type=simple
User=root
#Group=near
WorkingDirectory=/root/.near
ExecStart=/root/nearcore/target/release/neard run
Restart=on-failure
RestartSec=30
KillSignal=SIGINT
TimeoutStopSec=45
KillMode=mixed

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable neard
sudo systemctl restart neard

#seid tx staking create-validator \
#    --amount 1usei \
#    --pubkey "sei18ugzutfu9m0dwrrdg278h000k3x8zvwcmdyp2c" \
#    --moniker penton7 \
#    --chain-id "sei-testnet-2" \
#    --from penton7 \
#    --commission-rate "0.10" \
#    --commission-max-rate "0.20" \
#    --commission-max-change-rate "0.01" \
#    --min-self-delegation "1" \
#    --fees "2000usei"
#
#
#    seid tx staking create-validator \
#        --amount=1usei \
#        --pubkey=$PUBKEY \
#        --moniker=$MONIKER \
#        --chain-id "sei-testnet-2" \
#        --from=penton7 \
#        --commission-rate="0.10" \
#        --commission-max-rate="0.20" \
#        --commission-max-change-rate="0.01" \
#        --min-self-delegation="1" \
#        --fees="2000usei"
