#!/bin/bash

# Quai menu variable

    menu='./quai.sh'
    echo 'export menu='$menu >> $HOME/.bash_profile

IP=$(wget -qO- eth0.me)
echo 'export IP='$IP >> $HOME/.bash_profile
source $HOME/.bash_profile


PS3='Please enter your choice (input your option number and press enter): '
options=("Install" "Update" "Run" "Stop" "Check Node Logs" "Check Miner Logs"  )

select opt in "${options[@]}"
do
    case $opt in
        "Install")

            ######################## Preparation ########################

            # update & upgrade system
            sudo apt update && sudo apt upgrade -y

            # install dependencies
            sudo apt install curl build-essential git wget jq make gcc tmux mc -y

            # install GO
            wget -c https://golang.org/dl/go1.17.7.linux-amd64.tar.gz
            rm -rf /usr/local/go && tar -C /usr/local -xzf go1.17.7.linux-amd64.tar.gz
            export PATH=$PATH:/usr/local/go/bin
            
            
            ######################## Install Quai Node ########################

            # clone go-quai on to your machine
            git clone https://github.com/spruce-solutions/go-quai

            # move into go-quai directory
            cd $HOME/go-quai

            # generates go-quai binary
            make go-quai

            # copies environment variables to your machine
            cp network.env.dist network.env

            if [ !STATS_NAME ]; then
                read -p "Enter Miner Name: " STATS_NAME
                echo 'export STATS_NAME='$STATS_NAME >> $HOME/.bash_profile  
            fi
            echo 'export STATS_PASS=quainetworkbronze' >> $HOME/.bash_profile  
            source $HOME/.bash_profile

            sed -i -e "s/^STATS_NAME *=.*/STATS_NAME = \"$STATS_NAME\"/" $HOME/go-quai/network.env
            sed -i -e "s/^STATS_PASS *=.*/STATS_PASS = \"$STATS_PASS\"/" $HOME/go-quai/network.env

            
            ######################## Install Quai Miner ########################

            # go to parent directory
            cd $HOME
    
            # clone quai-manager
            git clone https://github.com/spruce-solutions/quai-manager

            # move into quai-manager directory
            cd $HOME/quai-manager

            # generate quai-manager binary
            make quai-manager

            # move into go-quai directory
            cd $HOME/go-quai

            # start running our full node that is primed for mining
            make run-full-mining NAME=$STATS_NAME PASSWORD=quainetworkbronze STATS_HOST=$IP

            # move to quai-manager directory
            cd $HOME/quai-manager

            # start mining
            make run-mine-background region=2 zone=2

        break
        ;;

        "Update")
            git pull origin main
            make quai-manager
        break
        ;;

        "Run")
            make run-mine-background region=1 zone=2
        break
        ;;

        "Stop")
            make stop
            break
        ;;

        "Check Node logs")
            cat $HOME/go-quai/nodelogs/prime.log
            break
        ;;

        "Check Miner Logs")
            cat logs/manager.log
        break
        ;;

    esac
done



# node logs
#cat $HOME/go-quai/nodelogs/prime.log

# miner logs
#cat logs/manager.log

# view logs of running nodes
#cat nodelogs/zone-1-1.log

# Stop go-quai
#make stop

# start full node without mining
#make run-full-node

# start full mining node
#make run-full-mining

