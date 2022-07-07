#!/bin/bash

# update & upgrade system
sudo apt update && sudo apt upgrade -y

# install dependencies
sudo apt install curl build-essential git wget jq make gcc tmux -y

# install GO
wget -c https://golang.org/dl/go1.17.7.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.17.7.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin


### Install Quai ###

# clone go-quai onto your machine
git clone https://github.com/spruce-solutions/go-quai

# move into go-quai directory
cd go-quai

# copies environment variables to your machine
cp network.env.dist network.env

# generates go-quai binary
make go-quai

# start full node without mining
make run-full-node

# start full mining node
# make run-full-mining

read -p "Enter STATS_NAME: " STATS_NAME
echo 'export STATS_NAME='$STATS_NAME >> $HOME/.bash_profile

STATS_PASS=quainetworkbronze
echo 'export STATS_PASS='$STATS_PASS >> $HOME/.bash_profile

source $HOME/.bash_profile

# view logs of running nodes
# cat nodelogs/zone-1-1.log

# Stop go-quai
# make stop

