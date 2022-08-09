######################################### Подготовка. Открытие портов. #########################################
sudo apt update && sudo apt upgrade && sudo apt install iptables-persistent && sudo apt install netfilter-persistent && sudo apt install mc -y

sudo sed -e 's/Port .*/Port 9000/' -e 's/#Port/Port/' -i /etc/ssh/sshd_config && cat /etc/ssh/sshd_config | grep Port && /etc/init.d/ssh restart

sudo netstat -tnlp | grep ssh

# Временно разрешаем все входящие и исходящие
sudo iptables -P INPUT ACCEPT
sudo iptables -P OUTPUT ACCEPT

# Очищаем таблицы
sudo iptables -F

# Разрашаем пакеты самому себе
sudo iptables -A INPUT -i lo -j ACCEPT

# Разрешаем соединения, которые начали мы
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Разрешаем соединения на SSH-сервер
sudo iptables -A INPUT -p tcp --dport 9000 -j ACCEPT


# Запрещаем все входящие и транзитные пакеты
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP

# и после этого сохранить правила

sudo netfilter-persistent save
sudo netfilter-persistent reload

# Ну и покажи, что получилось
iptables -L -nv

# зайти в терминал потом
ssh -p 25341 root@ip






# updating packages
sudo apt update && sudo apt upgrade -y

# installing dependencies
sudo apt install wget jq git libclang-dev cmake -y

# install Rust
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/installers/rust.sh)
# check version (should be 1.62.0)
rustc --version
# if not - delete from command below and install again
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/installers/rust.sh) \
-un

# create folder for node
mkdir -p $HOME/.sui

# fork repository
git clone https://github.com/dm-paull/sui

# go to project folder
cd sui

# create a branch with the original repository
git remote add upstream https://github.com/MystenLabs/sui

# pull up the current version
git fetch upstream

# switch to devnet version
git checkout --track upstream/devnet

# build binaries
cargo build --release

# move binary files to binaries folder
mv $HOME/sui/target/release/{sui,sui-node,sui-faucet} /usr/bin/

# go to parent directory
cd

# download genesis file
wget -qO $HOME/.sui/genesis.blob https://github.com/MystenLabs/sui-genesis/raw/main/devnet/genesis.blob

# copy config
cp $HOME/sui/crates/sui-config/data/fullnode-template.yaml \
$HOME/.sui/fullnode.yaml

# edit config
sed -i -e "s%db-path:.*%db-path: \"$HOME/.sui/db\"%; "\
"s%metrics-address:.*%metrics-address: \"0.0.0.0:9184\"%; "\
"s%json-rpc-address:.*%json-rpc-address: \"0.0.0.0:9000\"%; "\
"s%genesis-file-location:.*%genesis-file-location: \"$HOME/.sui/genesis.blob\"%; " $HOME/.sui/fullnode.yaml

# create service file
printf "[Unit]
Description=Sui node
After=network-online.target

[Service]
User=$USER
ExecStart=`which sui-node` --config-path $HOME/.sui/fullnode.yaml
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/suid.service

# run service
sudo systemctl daemon-reload
sudo systemctl enable suid
sudo systemctl restart suid

# add command to view logs
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n sui_log -v "sudo journalctl -fn 100 -u suid" -a

# check if command outputs transactions
wget -qO-  -t 1 -T 5 --header 'Content-Type: application/json' --post-data '{ "jsonrpc":"2.0", "id":1, "method":"sui_getRecentTransactions", "params":[5] }' "http://127.0.0.1:9000/" | jq



######################################### Docker #########################################

# Обновить пакеты и систему
sudo apt update && sudo apt upgrade -y

# Установить необходимые пакеты
sudo apt install wget jq bc build-essential -y

# Установить Docker
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/installers/docker.sh)

# Создать папку для ноды
mkdir -p $HOME/.sui

# Скачать файл генезиса
wget -qO $HOME/.sui/genesis.blob https://github.com/MystenLabs/sui-genesis/raw/main/devnet/genesis.blob

# Скачать конфиг ноды
wget -qO $HOME/.sui/fullnode.yaml https://github.com/MystenLabs/sui/raw/main/crates/sui-config/data/fullnode-template.yaml

# Отредактировать конфиг
sed -i -e "s%db-path:.*%db-path: \"$HOME/.sui/db\"%; "\
"s%metrics-address:.*%metrics-address: \"0.0.0.0:9184\"%; "\
"s%json-rpc-address:.*%json-rpc-address: \"0.0.0.0:9000\"%; "\
"s%genesis-file-location:.*%genesis-file-location: \"$HOME/.sui/genesis.blob\"%; " $HOME/.sui/fullnode.yaml

# Запустить контейнер с нодой
docker run -dit --name sui_node --restart always -u 0:0 \
  --network host -v $HOME/.sui:/root/.sui secord/sui \
  --config-path $HOME/.sui/fullnode.yaml

# Добавить команды в систему в виде переменных: Просмотр лога ноды и Сокращение команды для выполнения действий в контейнере
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n sui_log -v "docker logs sui_node -fn100" -a
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n sui -v "docker exec -it sui_node ./sui" -a

# Проверить, выводит ли команда транзакции
wget -qO-  -t 1 -T 5 --header 'Content-Type: application/json' --post-data '{ "jsonrpc":"2.0", "id":1, "method":"sui_getRecentTransactions", "params":[5] }' "http://127.0.0.1:9000/" | jq

### СОЗДАНИЕ КОШЕЛЬКА ###

# запуск cli-клиента Sui
sui client

# проверить что адрес создан
sui keytool list

### Публикация RPC ноды ###

# сначала открыть порт 9000
sudo ufw enable
sudo ufw allow 9000/tcp
# узнать свой IP
echo "http://`wget -qO- eth0.me`:9000/"
# отправить его в ветку node-ip-application

### Запросить токены с крана ###
# перейти в ветку devnet-faucet
!faucet 0x___

### Создать NFT ###
# создание NFT
sui client create-example-nft
