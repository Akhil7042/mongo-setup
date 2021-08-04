#!/bin/bash
destdir=mongos/.env

eth0ip=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
# eth0ip="192.168.1.7"
echo "eth0ip=$eth0ip" > "$destdir"
export eth0ip="$eth0ip"

# Setting up mongo config server
echo "Setting up mongo config server --------------"

echo "docker compose"
docker-compose -f config-server/docker-compose.yaml up -d
sleep 10
echo "connect to config"
mongo mongodb://"$eth0ip":27019 scripts/initiateConfigServer.js


# Setting up shard 1
echo "Setting up shard 1 ----------------"
echo "docker compose"
docker-compose -f shard1/docker-compose.yaml up -d
sleep 10
echo "initiateShard1"
mongo mongodb://"$eth0ip":27020 scripts/initiateReplicaSetForShard1.js


# Setting up MongoS
echo "setting up mongos ----------------------------"
echo "docker-compose mongos"
docker-compose -f mongos/docker-compose.yaml up -d
sleep 10

#adding Shard1 in mongos
echo "Adding shard1 -------------------------"
echo "mongo addshards"
mongo mongodb://"$eth0ip":27017 scripts/addShard1.js
sleep 10

#Setting up Shard2
echo "Setting up shard 2-----------------"
echo "docker compose"
docker-compose -f shard2/docker-compose.yaml up -d
sleep 10
echo "initiateShard2"
mongo mongodb://"$eth0ip":50004 scripts/initiateReplicaSetForShard2.js



#adding shard2
echo "Adding shard2 --------------------"
echo "mongo addshards"
mongo mongodb://"$eth0ip":27017 scripts/addShard2.js



echo "enableShardsOnDB"
mongo mongodb://"$eth0ip":27017 scripts/enableShardsOnDB.js


