#!/bin/bash
destdir=./mongos/.env

eth0ip=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
# eth0ip="10.0.1.116"
# eth0ip="192.168.1.7"

echo "eth0ip=$eth0ip" > "$destdir"
export eth0ip="$eth0ip"


echo "-----------------------creating keyfile for mongo auth --------------------"
# openssl rand -base64 741 > cnf/key.file

chmod 600 cnf/key.file
chown 999 cnd/key.file 






echo "--------------------Setting up mongo config server --------------"
docker-compose -f config-server/docker-compose.yaml up -d

echo "--------------------Setting up shard 1 --------------------"
docker-compose -f shard1/docker-compose.yaml up -d

echo "--------------------Setting up mongos ----------------------------"
docker-compose -f mongos/docker-compose.yaml up -d


echo "--------------------Setting up shard 2-----------------"
echo "docker compose"
docker-compose -f shard2/docker-compose.yaml up -d


echo "------------------connect to config ------------------"
sleep 5
echo "------------------run config scripts ------------------"

docker exec cfgsvr mongo --eval 'rs.initiate(
  {
    _id: "cfgrs",
    configsvr: true,
    members: [
      { _id : 0, host : "'$eth0ip':27019" },
    ]
  }
)'


echo "------------------connect to shard1 ------------------"
echo "-------------------initiateShard1----------------------"
docker exec shard1svr1 mongo --eval 'rs.initiate(
  {
    _id: "shard1rs",
    members: [
      { _id : 0, host : "'$eth0ip':27020" },
      { _id : 1, host : "'$eth0ip':27021" },
      { _id : 2, host : "'$eth0ip':27022" }
    ]
  }
)'



sleep 5

echo "------------------connect to mongos ------------------"
echo "-------------------Adding shard1 -------------------------"
docker exec mongos mongo --eval 'sh.addShard("shard1rs/'$eth0ip':27020,'$eth0ip':27021,'$eth0ip':27022")'
sleep 5


echo "--------------------connect to Shard2-------------------------"
echo "--------------------initiateShard2-------------------------"
docker exec shard2svr1 mongo --eval '
rs.initiate(
  {
    _id: "shard2rs",
    members: [
      { _id : 0, host : "'$eth0ip':50004" },
      { _id : 1, host : "'$eth0ip':50005" },
      { _id : 2, host : "'$eth0ip':50006" }
    ]
  }
)'


echo "------------------connect to mongos ------------------"
sleep 10
echo "---------------------Adding shard2 --------------------"
docker exec mongos mongo --eval '
sh.addShard("shard2rs/'$eth0ip':50004,'$eth0ip':50005,'$eth0ip':50006")
'



echo "-----------------------enableShardsOnDB--------------------"

docker exec mongos mongo --eval '
sh.enableSharding("creditDB")
sh.shardCollection("creditDB.users", {"username": "hashed"})
'

echo "------------------------Adding root user--------------------"
echo "------------------------username - root---------------------"
echo "------------------------password - 123456 ---------------------"

docker exec mongos mongo --eval '
db = db.getSiblingDB("admin");
db.createUser(
        {
            user:"root",
            pwd:"batch4-db",
            roles:[{role:"root",db:"admin"}]
        })

'




