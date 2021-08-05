### Mongo setup
run setupMongo.sh in './sharding' folder to setup whole mongo shards architecture
```
cd sharding
sudo sh setupMongo.sh
```

to remove all the containers
```
sudo sh removeContainers.sh
```


![mongo setup](structure.drawio.svg)


##### notes: 
> comment line 4 and add your own ip if you are running in windows

>if running on linux, then please dont make any change


#### MONGO CLUSTER AUTHENTICATION
1)generate keyfile with permissions

```
openssl rand -base64 741 > cnf/key.file
chmod 600 key.file
chown 999 key.file 
```

2)
Copy mongod.conf.orig to cnf/mongod.conf from any mongo docker container.
Add following lines

```
security:
  authorization: enabled
```

Mount both files as volume in all docker containers
(add following commands in docker compose files)
```
    volumes:
      - ../cnf/mongod.conf:/etc/mongod.conf
      - ../cnf/key.file:/etc/key.file

```

3)

Start all containers without any authentication.
```
sh setupContainersWithoutAuth.sh
```

Start containers with auth
```
sh startContainersWithAuth.sh
```
> Ultimate Command : run setupMongo.sh