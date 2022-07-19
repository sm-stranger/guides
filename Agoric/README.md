# Установка Agoric

## Для начала нужно сохранить конфигурацию сети в файл
```
curl https://main.agoric.net/network-config > $HOME/chain.json
```

## Далее нам нужно установить переменные
Here you have to put name of your moniker (validator) that will be visible in explorer
```
NODENAME=<MY_MONIKER_NAME_GOES_HERE>
```

## Обновляем систему
```
sudo apt update && sudo apt upgrade -y
```

## Установка зависимостей
```
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
```

## Сохранить и импортировать переменные в систему
```
echo "export NODENAME=$NODENAME" >> $HOME/.bash_profile
echo "export WALLET=wallet" >> $HOME/.bash_profile
echo "export CHAIN_ID=$(jq -r .chainName < $HOME/chain.json)" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

## Установка Node.js
```
curl https://deb.nodesource.com/setup_14.x | sudo bash
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt upgrade -y
sudo apt install nodejs=14.* yarn build-essential jq -y
```

## Установка Go
```
ver="1.18.2"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version
```

## Загрузка и сборка из исходного кода
```
git clone https://github.com/Agoric/ag0
cd ag0
git checkout agoric-3.1
make build
. $HOME/.bash_profile
cp $HOME/ag0/build/ag0 /usr/local/bin
```

## Настройка конфига
```
ag0 config chain-id $CHAIN_ID
ag0 config keyring-backend file
```

## Инициализация приложения
```
ag0 init $NODENAME --chain-id $CHAIN_ID
```

## Загрузка генезис файла
```
curl https://main.agoric.net/genesis.json > $HOME/.agoric/config/genesis.json 
```

## Установка сидов и пиров
```
peers=$(jq '.peers | join(",")' < $HOME/chain.json)
peers='"2c03e71116d1a2f9ba39a63a97058fcdeabfe2be@159.148.31.233:26656,ef12448f0f8671a195ab38c590cac713ad703a8b@146.70.66.202:26656,320dd22ee85e2b68f891b670331eb9fec9dc419e@80.64.208.63:26656,f095bb53006ebddcbbf29c8df70dddcba6419e36@142.93.145.13:26656,0c370d803934e3273c61b2577a0c6e91b9f677e0@139.59.7.33:26656,c03f4e7fe0f4c081b14f6731e74aa89ff2d4c197@84.244.95.237:26656,8c30ee29afc4b77cf98222edcc3fe823cf1e8306@195.201.106.244:26656,b2285313e3411e3d5bcbee72e526108e6bd07da4@185.147.80.110:26656,68c9c4e8388ed6936ff147ffe6b9913e79328957@35.215.62.66:26656,99968808ecae7bc41b14df3bcb51b724ee5f782f@134.209.154.162:26656,2d352e7a97cef2a6b253906d3741efaee16b6af0@64.227.14.179:26656,5a6c74c824805c3e75cea44df019b69db8fb935a@142.132.149.55:26656,0464c8dded70d01f5ab50a8d6047a6b27ddf2ccd@84.244.95.232:26656,9cd93ebaa554e68990ecec234de74e848c7755e7@137.184.45.31:10003,f4b809dcf7004b8a30eaa4e9bb0a65164368b75a@49.12.165.122:26656,4d0953252dd26b5ff96292bd2a836bd8a77f4eed@159.69.63.222:26656,f554d57fd9326a90580483e23cab8d728bfb232a@78.46.84.150:26656,c84170667fcf54024b24f05b2f9dd6608570ac8c@157.90.35.145:28656,cb6ae22e1e89d029c55f2cb400b0caa19cbe5523@15.223.138.194:26603,1da72d9acd9c26a332c99e5e5f91b586f1ebc7c4@3.14.237.44:26656"'
seeds=$(jq '.seeds | join(",")' < $HOME/chain.json)
sed -i.bak -e "s/^seeds *=.*/seeds = $seeds/; s/^persistent_peers *=.*/persistent_peers = $peers/" $HOME/.agoric/config/config.toml
```

# Устранение ошибки `Error: failed to parse log level`
```
sed -i.bak 's/^log_level/# log_level/' $HOME/.agoric/config/config.toml
```

## Активируем prometheus
```
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.agoric/config/config.toml
```

## Установка минимальной цены газа
```
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0ubld\"/" $HOME/.agoric/config/app.toml
```

## Выставляем RPC
```
sed -i 's#"tcp://127.0.0.1:26657"#"tcp://0.0.0.0:26657"#g' $HOME/.agoric/config/config.toml
```

# (ОПЦИОНАЛЬНО) настройка pruning
```
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.agoric/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.agoric/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.agoric/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.agoric/config/app.toml
```

## Сброс данных цепочки
```
ag0 unsafe-reset-all
```

## Создаем сервис
```
tee /etc/systemd/system/ag0.service > /dev/null <<EOF
[Unit]
Description=Agoric Cosmos daemon
After=network-online.target

[Service]
# ОПЦИОНАЛЬНО: включить отладочную информацию JS.
#SLOGFILE=.agoric/data/chain.slog
User=$USER
# ОПЦИОНАЛЬНО: включить отладочную информацию Cosmos
#ExecStart=$(which ag0) start --log_level=info --trace-store=.agoric/data/kvstore.trace
ExecStart=$(which ag0) start --log_level=info
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```

## Регистрируем и запускаем сервиса
```
sudo systemctl daemon-reload
sudo systemctl enable ag0
sudo systemctl restart ag0
```

## Используемые команды
### Управление сервисом
Проверка логов
```
journalctl -fu ag0 -o cat
```

Запуск сервиса
```
systemctl start ag0
```

Остановка сервиса
```
systemctl stop ag0
```

Перезапуск сервиса
```
systemctl restart ag0
```

### Информация о ноде
Информация о синхронизации
```
ag0 status 2>&1 | jq .SyncInfo
```

Информация о валидаторе
```
ag0 status 2>&1 | jq .ValidatorInfo
```

Информация о ноде
```
ag0 status 2>&1 | jq .NodeInfo
```

Показать ID ноды
```
ag0 show-node-id
```

### Операции с кошельком
Список кошельков
```
ag0 keys list
```

Восстановить кошелек
```
ag0 keys add $WALLET --recover
```

Удалить кошелек
```
ag0 keys delete $WALLET
```

Получить баланс
```
ag0 query bank balances $WALLET_ADDRESS
```

Перевод средств
```
ag0 tx bank send $WALLET_ADDRESS <TO_WALLET_ADDRESS> 10000000ubld
```

### Голосование
```
ag0 tx gov vote 1 yes --from $WALLET --chain-id=$CHAIN_ID
```

### Стейкинг, делегация, реварды
Делегировать ставку
```
ag0 tx staking delegate $VALOPER_ADDRESS 10000000ubld --from=$WALLET --chain-id=$CHAIN_ID --gas=auto
```

Переделегировать стейк от валидатора к другому валидатору
```
ag0 tx staking redelegate <srcValidatorAddress> <destValidatorAddress> 10000000ubld --from=$WALLET --chain-id=$CHAIN_ID --gas=auto
```

Вывести реварды
```
ag0 tx distribution withdraw-all-rewards --from=$WALLET --chain-id=$CHAIN_ID --gas=auto
```

Вывести реварды с комиссией
```
ag0 tx distribution withdraw-rewards $VALOPER_ADDRESS --from=$WALLET --commission --chain-id=$CHAIN_ID
```

### Управление валидатором
Редактирвоать валидатора
```
ag0 tx staking edit-validator \
--moniker=$NODENAME \
--identity=1C5ACD2EEF363C3A \
--website="http://kjnodes.com" \
--details="Providing professional staking services with high performance and availability. Find me at Discord: kjnodes#8455 and Telegram: @kjnodes" \
--chain-id=$CHAIN_ID \
--from=$WALLET
```

Вытащить валидатора из тюрьмы
```
ag0 tx slashing unjail \
  --broadcast-mode=block \
  --from=$WALLET \
  --chain-id=$CHAIN_ID \
  --gas=auto
```

### Удалить ноду

```
systemctl stop ag0
systemctl disable ag0
rm /etc/systemd/system/ag0.service -rf
rm $(which ag0) -rf
rm $HOME/.agoric* -rf
rm $HOME/ag0 -rf