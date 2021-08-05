#!/bin/bash
docker-compose -f config-server/docker-compose.yaml down
docker-compose -f mongos/docker-compose.yaml down
docker-compose -f shard1/docker-compose.yaml down
docker-compose -f shard2/docker-compose.yaml  down