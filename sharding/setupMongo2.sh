#!/bin/bash
destdir=./mongos/.env

# eth0ip=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
eth0ip="192.168.1.7"
echo "eth0ip=$eth0ip" > "$destdir"
export eth0ip="$eth0ip"


# Setting up mongo config server
echo "--------------------Setting up mongo config server --------------"
docker-compose -f config-server/docker-compose.yaml up -d

sleep 30
# Setting up shard 1
echo "--------------------Setting up shard 1 --------------------"
docker-compose -f shard1/docker-compose.yaml up -d
sleep 90
# Setting up MongoS
echo "--------------------Setting up mongos ----------------------------"
docker-compose -f mongos/docker-compose.yaml up -d
sleep 30
#Setting up Shard2
echo "--------------------Setting up shard 2-----------------"
echo "docker compose"
docker-compose -f shard2/docker-compose.yaml up -d


sleep 30
echo "------------------connect to config ------------------"
docker exec cfgsvr mongo
sleep 5
echo "------------------run config scripts ------------------"
docker exec cfgsvr mongo < scripts/initiateConfigServer.js


sleep 40
echo "------------------connect to shard1 ------------------"
docker exec shard1svr1 mongo
sleep 5 
echo "-------------------initiateShard1----------------------"
docker exec shard1svr1 mongo  < scripts/initiateReplicaSetForShard1.js



sleep 40

#adding Shard1 in mongos
echo "------------------connect to mongos ------------------"
docker exec mongos mongo
sleep 5

echo "-------------------Adding shard1 -------------------------"
docker exec mongos mongo < scripts/addShard1.js
sleep 40


echo "--------------------connect to Shard2-------------------------"
docker exec shard2svr1 mongo
sleep 10
echo "--------------------initiateShard2-------------------------"
docker exec shard2svr1 mongo < scripts/initiateReplicaSetForShard2.js
sleep 40


echo "------------------connect to mongos ------------------"
docker exec mongos mongo
sleep 10
#adding shard2
echo "---------------------Adding shard2 --------------------"
docker exec mongos mongo < scripts/addShard2.js
sleep 40


# echo "enableShardsOnDB"
docker exec mongos mongo < scripts/enableShardsOnDB.js



