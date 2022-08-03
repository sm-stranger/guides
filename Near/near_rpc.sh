# prerequisites
sudo apt update && sudo apt upgrade -y
apt install -y git binutils-dev libcurl4-openssl-dev zlib1g-dev libdw-dev libiberty-dev cmake gcc g++ python docker.io protobuf-compiler libssl-dev pkg-config clang llvm cargo awscli jq mc curl screen
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/bin
rustc --version


# clone nearcore project from GitHub
git clone https://github.com/near/nearcore
cd nearcore
git fetch origin --tags

git checkout tags/1.28.0 -b mynode

# compile nearcore binary
make release

# initialize working directory
./target/release/neard --home ~/.near init --chain-id mainnet --download-genesis --download-config

# replacing the config.json
rm ~/.near/config.json
wget https://s3-us-west-1.amazonaws.com/build.nearprotocol.com/nearcore-deploy/mainnet/config.json -P ~/.near/

# change config.json
# "archive": true

# get data backup
aws s3 --no-sign-request cp s3://near-protocol-public/backups/mainnet/archive/latest .
LATEST=$(cat latest)
aws s3 --no-sign-request cp --no-sign-request --recursive s3://near-protocol-public/backups/mainnet/archive/$LATEST ~/.near/data

# get data backup (with s5cmd)
docker run --rm -v ~/.aws:/root/.aws s5cmd cp s3://near-protocol-public/backups/mainnet/archive/latest .
LATEST=$(cat latest)
docker run --rm -v ~/.aws:/root/.aws cp --no-sign-request --recursive s3://near-protocol-public/backups/mainnet/archive/$LATEST ~/.near/data

docker run --rm -v ~/.aws:/root/.aws peakcom/s5cmd cp s3://near-protocol-public/backups/mainnet/archive/latest .
LATEST=$(cat latest)
docker run --rm -v ~/.aws:/root/.aws peakcom/s5cmd cp --no-sign-request --recursive s3://near-protocol-public/backups/mainnet/archive/$LATEST ~/.near/data

# run the node
./nearcore/target/release/neard --home ~/.near run


# screen session
screen -S near

# Ctrl+a c Create a new window (with shell).
# Ctrl+a " List all windows.
# Ctrl+a 0 Switch to window 0 (by number).
# Ctrl+a A Rename the current window.
# Ctrl+a S Split current region horizontally into two regions.
# Ctrl+a | Split current region vertically into two regions.
# Ctrl+a tab Switch the input focus to the next region.
# Ctrl+a Ctrl+a Toggle between the current and previous windows
# Ctrl+a Q Close all regions but the current one.
# Ctrl+a X Close the current region.



./nearcore/target/release/neard --home ~/.near


# install npm

# install with nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh -bash
source ~/.bashrc
nvm list-remote
nvm install #version

# install near-cli
npm install -g near-cli

# set up a global environment variable
export NEAR_ENV=mainnet
export NEAR_CLI_MAINNET_RPC_SERVER_URL=<put_your_rpc_server_url_here>


# install go
ver="1.18.2"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version


# install Docker
sudo apt install docker.io curl -y \
&& sudo systemctl start docker \
&& sudo systemctl enable docker
