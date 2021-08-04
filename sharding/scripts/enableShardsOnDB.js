sh.enableSharding("creditDB")
sh.shardCollection("creditDB.users", {"username": "hashed"})
db.users.getShardDistribution()
