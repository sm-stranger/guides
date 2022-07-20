# Setup NEAR-CLI
# First, let's make sure the Debian machine is up-to-date.
sudo apt update && sudo apt upgrade -y

# Install developer tools, Node.js, and npm
# First, we will start with installing Node.js and npm:
curl -sL https://deb.nodesource.com/setup_17.x | sudo -E bash -  
sudo apt install build-essential nodejs
PATH="$PATH"

# install go, make
sudo apt-get install gcc g++ make

# install YARN
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/yarnkey.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install yarn


# Install NEAR-CLI
sudo npm install -g near-cli

export NEAR_ENV=mainnet