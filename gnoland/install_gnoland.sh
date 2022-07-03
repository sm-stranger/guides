#!/bin/bash

# открытие портов
sudo ufw default allow outgoing
sudo ufw default deny incoming
sudo ufw allow ssh/tcp
sudo ufw limit ssh/tcp
sudo ufw allow 26657
sudo ufw enable -y
sudo ufw reload

# подготовка сервера
sudo apt update && sudo apt upgrade -y
sudo apt install make clang pkg-config libssl-dev libclang-dev build-essential git curl ntp jq llvm tmux htop screen -y

# установка GO
ver="1.18.2"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version

# установка ноды
git clone https://github.com/gnolang/gno/
cd gno
make

gnokey=./build/gnokey

# создаем кошелек
$gnokey add account > $HOME/config.txt
cat $HOME/gno/config.txt

# установка переменной address


if [ !address ]; then
    read -p 'Скопируйте и вставьте адрес кошелька (указан в выводе выше: "addr:" )' address
    echo 'export address='$address >> $HOME/.bash_profile
fi
source $HOME/.bash_profile

# получение токенов
balance="$(./build/gnokey query "bank/balances/"$address --remote gno.land:36657)"
while true;
    do  curl 'https://gno.land:5050/' --data-raw 'toaddr='$address;
        balance="$(./build/gnokey query "bank/balances/"$address --remote gno.land:36657)";
        echo $balance;
        sleep 2;
    done


# регистрация аккаунта
$gnokey query auth/accounts/$address --remote gno.land:36657

read -p "User Name: " username
echo 'export username='$username >> $HOME/.bash_profile
read -p "Account Number: " account_number
read -p "Sequence Number: " sequence_number
echo 'export account_number='$account_number >> $HOME/.bash_profile
echo 'export sequence_number='$sequence_number >> $HOME/.bash_profile
source $HOME/.bash_profile


# создаем фаил с информацией о нашей регистрации
$gnokey maketx call $address --pkgpath "gno.land/r/users" --func "Register" --gas-fee 1gnot --gas-wanted 3000000 --send "2000gnot" --args "" --args $username --args "" > unsigned.tx

# создаем транзакцию
$gnokey sign $address --txpath unsigned.tx --chainid testchain --number $account_number --sequence $sequence_number > signed.tx

# проводим транзакцию
$gnokey broadcast signed.tx --remote gno.land:36657

# выполняем задание
read -p "Вставьте ссылку на свою работу: " url
echo 'export url='$url >> $HOME/.bash_profile
source $HOME/.bash_profile
$gnokey maketx call $address --pkgpath "gno.land/r/boards" --func "CreateReply" --gas-fee 1gnot --gas-wanted 3000000 --send "" --broadcast true --chainid testchain --args "1" --args "8" --args "8" --args "<URL>" --remote gno.land:36657