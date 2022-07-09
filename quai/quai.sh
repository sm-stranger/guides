#!/bin/bash

# Quai menu variable
if [ !$quai ]; then
    quai='./quai.sh'
    echo 'export quai='$quai >> $HOME/.bash_profile
    source $HOME/.bash_profile
fi


PS3='Please enter your choice (input your option number and press enter): '
options=("Install" "Update" "Run" "Stop" "Check Logs"  )

select opt in "${options[@]}"
do
    case $opt in
        "Install")

            ######################## Preparation ########################

            # update & upgrade system
            sudo apt update && sudo apt upgrade -y

            # install dependencies
            sudo apt install curl build-essential git wget jq make gcc tmux -y

            # install GO
            wget -c https://golang.org/dl/go1.17.7.linux-amd64.tar.gz
            rm -rf /usr/local/go && tar -C /usr/local -xzf go1.17.7.linux-amd64.tar.gz
            export PATH=$PATH:/usr/local/go/bin
            
            
            ######################## Install Quai Node ########################
            
            # go to parent directory
            cd $HOME

            # clone go-quai onto your machine
            git clone https://github.com/spruce-solutions/go-quai

            # move into go-quai directory
            cd go-quai

            if [ !STATS_NAME ]; then
                read -p "Enter Miner Name: " STATS_NAME
                echo 'export STATS_NAME='$STATS_NAME >> $HOME/.bash_profile  
            fi
            echo 'export STATS_PASS=quainetworkbronze' >> $HOME/.bash_profile  
            source $HOME/.bash_profile

            # copies environment variables to your machine
            cp network.env.dist network.env

            # generates go-quai binary
            make go-quai

            
            ######################## Install Quai Miner ########################

            # go to parent directory
            cd $HOME
    
            # clone quai-manager
            git clone https://github.com/spruce-solutions/quai-manager

            # move into quai-manager directory
            cd quai-manager

            # generate quai-manager binary
            make quai-manager

            # move into go-quai directory
            cd go-quai

            # start running our full node that is primed for mining
            make run-full-mining

            # move into quai-manager directory
            cd quai-manager

            # start mining
            make run-mine-background region=1 zone=2

        break
        ;;

        "Update")
            update
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
        "Check logs")
            cat logs/manager.log
            break
        ;;
        "Check Miner Logs")
            cat logs/manager.log
        ;;
    esac
done




# view logs of running nodes
# cat nodelogs/zone-1-1.log

# Stop go-quai
# make stop

# start full node without mining
    #make run-full-node

    # start full mining node
    #make run-full-mining