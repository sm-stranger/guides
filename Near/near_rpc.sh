# prerequisites
sudo apt update && sudo apt upgrade -y
apt install -y git binutils-dev libcurl4-openssl-dev zlib1g-dev libdw-dev libiberty-dev cmake gcc g++ python docker.io protobuf-compiler libssl-dev pkg-config clang llvm cargo awscli

# clone nearcore project from GitHub
git clone https://github.com/near/nearcore
cd nearcore
git fetch origin --tags

git checkout tags/1.25.0 -b mynode

# compile nearcore binary
make release

# initialize working directory
./target/release/neard --home ~/.near init --chain-id mainnet --download-genesis --download-config

# replacing the config.json
rm ~/.near/config.json
wget https://s3-us-west-1.amazonaws.com/build.nearprotocol.com/nearcore-deploy/mainnet/config.json -P ~/.near/

# get data backup
aws s3 --no-sign-request cp s3://near-protocol-public/backups/mainnet/rpc/latest .
LATEST=$(cat latest)
aws s3 --no-sign-request cp --no-sign-request --recursive s3://near-protocol-public/backups/mainnet/rpc/$LATEST ~/.near/data

# run the node
./target/release/neard --home ~/.near run


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