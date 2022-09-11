#!/bin/bash

# Quai menu variable


PS3='Please enter your choice (input your option number and press enter): '
options=("Install" "Update" "Run" "Stop" "Check Node Logs" "Check Miner Logs"  )

select opt in "${options[@]}"
do
    case $opt in
        "Install")

            menu='./quai.sh'
            echo 'export menu='$menu >> $HOME/.bash_profile

            IP=$(wget -qO- eth0.me)
            echo 'export IP='$IP >> $HOME/.bash_profile
            source $HOME/.bash_profile

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

            # copies environment variables to your machine
            cp network.env.dist network.env

            # generates go-quai binary
            make go-quai

            read -p "Enter PRIME_COINBASE Address: " PRIME_COIMBASE
            sed -i -e "s/^PRIME_COINBASE *=.*/PRIME_COINBASE = \"$address\"/" $HOME/go-quai/network.env




            
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
            make run-full-mining

            # move to quai-manager directory
            cd $HOME/quai-manager

            # start mining 
            read -p "Choose region for mining: " region
            read -p "Choose zone for mining: " zone
            make run-mine-background region=$region zone=$zone

        break
        ;;

        "Update")
            git pull origin main
            make go-quai
            make quai-manager
        break
        ;;

        "Run")
            make run-mine-background region=$region zone=$zone
        break
        ;;

        "Stop")
            ###### CHANGE: stop both node and miner, miner first node second ######
            cd $HOME/go-quai
            make stop
            cd $HOME/quai-manager
            make stop
        break
        ;;

        "Check Node logs")
            ###### CHANGE: allow users to check nodelogs in any region/zone that they would like ######
            PS3 "Choose which logs you want to see: "
            options=( "Prime", "Region/Zone Logs" )
            select opt in "${options[@]}"
            do
                case $opt in 
                    "Prime")
                        cat $HOME/go-quai/nodelogs/prime.log
                        break
                    ;;

                    "Region")
                        read -p "Enter region ( 1 or 2 or 3 ) for output logs:" region
                        cat $HOME/go-quai/nodelogs/region-$region.log

                    "Zone"
                        read -p "Enter region ( 1 or 2 or 3 ) for output logs:" region
                        read -p "Enter zone ( 1 or 2 or 3 ) for output logs:" zone
                        cat $HOME/go-quai/nodelogs/zone-$region-$zone.log
                        
                esac
            done

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

## ADDITIONAL INFO ##
# Locations to mine - regions can be 1 through 3, zones can be 1 through 3 as well!
# Locations to check logs: prime, region-1, region-2, region-3, zone-1-1, zone-1-2, zone-1-3, zone-2-1, zone-2-2, zone-2-3, zone-3-1, zone-3-2, zone-3-3