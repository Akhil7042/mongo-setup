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
chown 999 cnf/key.file 






echo "--------------------Setting up mongo config server --------------"
docker-compose -f config-server/docker-compose-product.yaml up -d
docker-compose -f config-server/docker-compose-card.yaml up -d
docker-compose -f config-server/docker-compose-user.yaml up -d


echo "--------------------Setting up shard 1 --------------------"
docker-compose -f shard1/docker-compose-product.yaml up -d
docker-compose -f shard1/docker-compose-card.yaml up -d
docker-compose -f shard1/docker-compose-user.yaml up -d

echo "--------------------Setting up mongos ----------------------------"
docker-compose -f mongos/docker-compose-product.yaml up -d
docker-compose -f mongos/docker-compose-card.yaml up -d
docker-compose -f mongos/docker-compose-user.yaml up -d


echo "--------------------Setting up shard 2-----------------"
echo "docker compose"
docker-compose -f shard2/docker-compose-product.yaml up -d


echo "------------------connect to config ------------------"
sleep 5
echo "------------------run config scripts ------------------"

docker exec cfgsvr-product mongo --eval 'rs.initiate(
  {
    _id: "cfgrs-product",
    configsvr: true,
    members: [
      { _id : 0, host : "'$eth0ip':4010" },
    ]
  }
)'

docker exec cfgsvr-card mongo --eval 'rs.initiate(
  {
    _id: "cfgrs-card",
    configsvr: true,
    members: [
      { _id : 0, host : "'$eth0ip':4000" },
    ]
  }
)'

docker exec cfgsvr-user mongo --eval 'rs.initiate(
  {
    _id: "cfgrs-user",
    configsvr: true,
    members: [
      { _id : 0, host : "'$eth0ip':4020" },
    ]
  }
)'


echo "------------------connect to shard1 ------------------"
echo "-------------------initiateShard1----------------------"
docker exec shard1svr1-product mongo --eval 'rs.initiate(
  {
    _id: "shard1rs-product",
    members: [
      { _id : 0, host : "'$eth0ip':5010" },
      { _id : 1, host : "'$eth0ip':5011" },
      { _id : 2, host : "'$eth0ip':5012" }
    ]
  }
)'

docker exec shard1svr1-card mongo --eval 'rs.initiate(
  {
    _id: "shard1rs-card",
    members: [
      { _id : 0, host : "'$eth0ip':5000" },
      { _id : 1, host : "'$eth0ip':5001" },
      { _id : 2, host : "'$eth0ip':5002" }
    ]
  }
)'

docker exec shard1svr1-user mongo --eval 'rs.initiate(
  {
    _id: "shard1rs-user",
    members: [
      { _id : 0, host : "'$eth0ip':5030" },
      { _id : 1, host : "'$eth0ip':5031" },
      { _id : 2, host : "'$eth0ip':5032" }
    ]
  }
)'



sleep 5

echo "------------------connect to mongos ------------------"
echo "-------------------Adding shard1 -------------------------"
docker exec mongos-product mongo --eval 'sh.addShard("shard1rs-product/'$eth0ip':5010,'$eth0ip':5011,'$eth0ip':5012")'
docker exec mongos-card mongo --eval 'sh.addShard("shard1rs-card/'$eth0ip':5000,'$eth0ip':5001,'$eth0ip':5002")'
docker exec mongos-user mongo --eval 'sh.addShard("shard1rs-user/'$eth0ip':5030,'$eth0ip':5031,'$eth0ip':5032")'
sleep 5


echo "--------------------connect to Shard2-------------------------"
echo "--------------------initiateShard2-------------------------"
docker exec shard2svr1-product mongo --eval '
rs.initiate(
  {
    _id: "shard2rs-product",
    members: [
      { _id : 0, host : "'$eth0ip':5013" },
      { _id : 1, host : "'$eth0ip':5014" },
      { _id : 2, host : "'$eth0ip':5015" }
    ]
  }
)'


echo "------------------connect to mongos ------------------"
sleep 10
echo "---------------------Adding shard2 --------------------"
docker exec mongos mongo --eval '
sh.addShard("shard2rs-product/'$eth0ip':5013,'$eth0ip':5014,'$eth0ip':5015")
'



# echo "-----------------------enableShardsOnDB--------------------"

# docker exec mongos mongo --eval '
# sh.enableSharding("creditDB")
# sh.shardCollection("creditDB.users", {"username": "hashed"})
# '

# echo "------------------------Adding root user--------------------"
# echo "------------------------username - root---------------------"
# echo "------------------------password - 123456 ---------------------"

# docker exec mongos mongo --eval '
# db = db.getSiblingDB("admin");
# db.createUser(
#         {
#             user:"root",
#             pwd:"batch4-db",
#             roles:[{role:"root",db:"admin"}]
#         })

# '




