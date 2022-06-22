#!/bin/bash

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
make install

# создаем кошелек (generate) или восстанавливаем уже существующий (--recover)
./build/gnokey generate
./build/gnokey add account --recover

# список кошельков
./build/gnokey list

# установка переменной address
read -p "Wallet Address: " address
echo 'export address='$address >> $HOME/.bash_profile
source $HOME/.bash_profile

# получение токенов
while true;
    do curl 'https://gno.land:5050/'
        --data-raw 'toaddr='$address;
        ./build/gnokey query "bank/balances/"$address
        --remote gno.land:36657;
        sleep 2;
    done


# регистрация нашего аккаунта
./build/gnokey query auth/accounts/$address --remote gno.land:36657

read -p "User Name: " username
read -p "Account Number: " account_number
read -p "Sequence Number: " sequence_number
echo 'export username='$username >> $HOME/.bash_profile
echo 'export account_number='$account_number >> $HOME/.bash_profile
echo 'export sequence_number='$sequence_number >> $HOME/.bash_profile
source $HOME/.bash_profile


# создаем фаил, который будет содержать информацию о нашей регистрации
./build/gnokey maketx call $address --pkgpath "gno.land/r/users" --func "Register" --gas-fee 1gnot --gas-wanted 3000000 --send "2000gnot" --args "" --args $username --args "" > unsigned.tx

# создаем транзакцию
./build/gnokey sign $address --txpath unsigned.tx --chainid testchain --number $account_number --sequence $sequence_number > signed.tx

# проводим транзакцию
./build/gnokey broadcast signed.tx --remote gno.land:36657

# выполняем задание
read -p "Вставьте ссылку на свою работу: " url
echo 'export url='$url >> $HOME/.bash_profile
source $HOME/.bash_profile
./build/gnokey maketx call $address --pkgpath "gno.land/r/boards" --func "CreateReply" --gas-fee 1gnot --gas-wanted 3000000 --send "" --broadcast true --chainid testchain --args "1" --args "8" --args "8" --args "<URL>" --remote gno.land:36657
