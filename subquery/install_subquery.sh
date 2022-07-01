################################################# PREPARE SERVER #################################################

# update & upgrade system
sudo apt update && sudo apt upgrade -y

# install dependencies
sudo apt install wget jq build-essential nano unzip -y

# install Docker
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/installers/docker.sh)

# enable UFW
sudo apt install ufw -y
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 8000
sudo ufw allow 9090
sudo ufw allow 9100
sudo ufw allow 3000:3100/tcp

################################################# INSTALL NODE #################################################

# clone repository
mkdir subquery-indexer
curl https://raw.githubusercontent.com/subquery/indexer-services/main/docker-compose.yml -o $HOME/subquery-indexer/docker-compose.yml

# create service
printf "[Unit]
Description=Subquery systemd service
After=network.target
StartLimitIntervalSec=0

[Service]
User=$USER
Type=simple
Restart=on-failure
RestartSec=10
User=root
SyslogIdentifier=subquery
SyslogFacility=local7
KillSignal=SIGHUP
WorkingDirectory=$HOME/subquery-indexer
ExecStart=`which docker-compose` up -d

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/subquery.service

# run service
systemctl enable subquery.service 
systemctl start subquery.service 
systemctl status subquery.service

# waiting 2 minutes and check containers
sleep 2

docker ps