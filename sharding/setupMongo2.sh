#!/bin/bash
destdir=./mongos/.env

eth0ip=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
# eth0ip="192.168.43.216"
echo "eth0ip=$eth0ip" > "$destdir"
export eth0ip="$eth0ip"


# Setting up mongo config server
echo "--------------------Setting up mongo config server --------------"
docker-compose -f config-server/docker-compose.yaml up -d

sleep 20
# Setting up shard 1
echo "--------------------Setting up shard 1 --------------------"
docker-compose -f shard1/docker-compose.yaml up -d
sleep 5
# Setting up MongoS
echo "--------------------Setting up mongos ----------------------------"
docker-compose -f mongos/docker-compose.yaml up -d
sleep 5
#Setting up Shard2
echo "--------------------Setting up shard 2-----------------"
echo "docker compose"
docker-compose -f shard2/docker-compose.yaml up -d


sleep 5
echo "------------------connect to config ------------------"
docker exec cfgsvr mongo mongodb://"$eth0ip":27019 < scripts/initiateConfigServer.js


sleep 10

echo "-------------------initiateShard1----------------------"
docker exec shard1svr1 mongo mongodb://"$eth0ip":27020 < scripts/initiateReplicaSetForShard1.js



sleep 10

#adding Shard1 in mongos
echo "-------------------Adding shard1 -------------------------"
docker exec mongos mongo mongodb://"$eth0ip":27017 < scripts/addShard1.js
sleep 10


sleep 10
echo "--------------------initiateShard2-------------------------"
docker exec shard2svr1 mongo mongodb://"$eth0ip":50004 < scripts/initiateReplicaSetForShard2.js



#adding shard2
echo "---------------------Adding shard2 --------------------"
docker exec mongos mongo mongodb://"$eth0ip":27017 < scripts/addShard2.js



# echo "enableShardsOnDB"
docker exec mongos mongo mongodb://"$eth0ip":27017 < scripts/enableShardsOnDB.js



