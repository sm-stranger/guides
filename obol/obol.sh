############################################ PREPARATION ############################################

sudo apt update && sudo apt upgrade -y

sudo apt install make clang pkg-config libssl-dev libclang-dev build-essential git curl ntp jq llvm tmux htop screen unzip -y

sudo apt install docker.io -y

git clone https://github.com/docker/compose

cd compose

git checkout v2.6.1

make

cd

mv compose/bin/docker-compose /usr/bin

docker-compose version
# v2.6.1


############################################ INSTALL ############################################

git clone https://github.com/ObolNetwork/charon-distributed-validator-node.git

chmod o+w charon-distributed-validator-node

cd charon-distributed-validator-node

docker run --rm -v "$(pwd):/opt/charon" ghcr.io/obolnetwork/charon:v0.8.1 create enr
#Выдаст длинный код, который нужно целиком вставить в форму. Выглядит он так:
"enr:-JG4QHAG_yDgdshF6Ia9dQRW5V6b7lb-lb-Ax1.."


############################################ BACKUP ############################################

cd
cd charon-distributed-validator-node/.charon
# В этой папке ваш ключ "charon-enr-private-key" который нужно сохранить себе на компьютер используя программу MobaxTerm или Termius для MacBook
# or
cat charon-distributed-validator-node/.charon/charon-enr-private-key


############################################ DELETE NODE ############################################

rm -rf charon-distributed-validator-node

