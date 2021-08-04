#!/bin/bash
docker-compose -f config-server/docker-compose.yaml rm -fsv
docker-compose -f mongos/docker-compose.yaml rm -fsv
docker-compose -f shard1/docker-compose.yaml rm -fsv
docker-compose -f shard2/docker-compose.yaml rm -fsv