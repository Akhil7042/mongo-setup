#!/bin/bash
destdir=./mongos/.env

# eth0ip=$(ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
# eth0ip="10.0.1.116"
eth0ip="192.168.1.7"

echo "eth0ip=$eth0ip" > "$destdir"
export eth0ip="$eth0ip"


echo "--------------------Setting up mongo config server --------------"
docker-compose -f config-server/docker-compose-auth.yaml up -d

echo "--------------------Setting up shard 1 --------------------"
docker-compose -f shard1/docker-compose-auth.yaml up -d

echo "--------------------Setting up mongos ----------------------------"
docker-compose -f mongos/docker-compose-auth.yaml up -d


echo "--------------------Setting up shard 2-----------------"
echo "docker compose"
docker-compose -f shard2/docker-compose-auth.yaml up -d
