#!/bin/bash

###################
## Process Flags ##
###################
witness=0
accountName=""
privActiveKey=""
snapshotBase="https://snap.rishipanthee.com/snapshots/"
gitURL="https://github.com/primersion/steemsmartcontracts.git"
gitBranch="hive-engine-restore"
fullnode=1
ipv6=1
while getopts n:wla:p:4s: flag
do
    case "${flag}" in
        w)
         witness=1
        ;;
        l) 
          fullnode=0
          ;;
        a) 
          accountName=${OPTARG}
          ;;
        p) 
          privActiveKey=${OPTARG}
          ;;
        4) 
          ipv6=0
          ;;
        s)
          snapshotBase=${OPTARG}
          ;;
    esac
done

##################
## INIT UPDATES ##
##################
sudo apt update
sudo apt upgrade -y

#########################
## Install  NodeJS/NPM ##
#########################
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt install nodejs -y
sudo apt install npm -y
hash -r
sudo npm install -g npm

##########################
## Install Dependencies ##
##########################
wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list
sudo apt update -y
sudo apt install git -y
sudo apt install screen -y
sudo apt install ufw -y
sudo apt install dnsutils -y
sudo apt install mongodb-org -y
sudo apt install build-essential -y
sudo npm i -g pm2

################
## Clone Repo ##
################
git clone $gitURL
cd steemsmartcontracts
git checkout $gitBranch

########################
## Start Witness Only ##
########################
if [ 1 -eq $witness ];
then
############
## Get IP ##
############
  pubIP=""
  if [ 1 -eq $ipv6 ];
  then
    pubIP=`(dig @resolver1.ipv6-sandbox.opendns.com AAAA myip.opendns.com +short -6)`
    if [ -z "$pubIP" ];
    then
      echo "No IPv6 detected, setting to v4"
      ipv6=0
    fi
  fi

  if [ 0 -eq $ipv6 ];
  then
    pubIP=`(dig @resolver4.opendns.com myip.opendns.com +short -4)`
    if [ -z "$pubIP" ];
    then
      echo "No IP detected, you'll have to manually configure that"
    fi
  fi

  ####################
  ##  Write To .env ##
  ####################
  echo "ACTIVE_SIGNING_KEY=$privActiveKey" >> .env
  echo "ACCOUNT=$accountName" >> .env
  echo "IP=$pubIP" >> .env
fi
######################
## End Witness Only ##
######################


############################
## Configure Replica Sets ##
############################
sudo echo 'replication:' >> /etc/mongod.conf
sudo echo '  replSetName: "rs0"' >> /etc/mongod.conf

###################
## Restart Mongo ##
###################
sudo systemctl stop mongod
sudo systemctl start mongod

###############################
## Enable Replica Sets Mongo ##
###############################
sleep 30 ## This sleep is needed because mongo takes a while to start up. 30 seconds is overkill but better safe than sorry.
mongo --eval "rs.initiate()"
mongo --eval "db.adminCommand({setParameter:1, internalQueryMaxBlockingSortMemoryUsageBytes:2097152000})" # Sets to 2 GB

###########################################
## Enable 2GB Swap If Less Than 4 GB RAM ##
###########################################
totalm=$(free -m | awk '/^Mem:/{print $2}')
if [ totalm -lt 4096 ];
then
  fallocate -l 2G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
fi

##################################
## Get And Load Latest Snapshot ##
##################################
if [ 0 -eq $fullnode ];
then
  snapshotBase="${snapshotBase}light"
  sed -i 's/"lightNode": false/"lightNode": true/g' config.json
fi

npm ci
node restore_partial.js -d -s "$snapshotBase"

#################
## Start it up ##
#################
pm2 start app.js --no-treekill --kill-timeout 10000 --no-autorestart --name engnode