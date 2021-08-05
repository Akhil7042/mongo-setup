### Mongo setup


To Setup mongodb sharded cluster with authentication enabled (on linux machine), run following command
```
cd sharding
sudo run setupMongo.sh
```

### notes: 
>if you are running windows comment line 4 in setupContainersWithAuth.sh setupContainersWithoutAuth.sh and add your own ip if you are running in windows

>if running on linux, then please dont make any change


to remove all the containers
```
sudo sh stopContainers.sh
```


![mongo setup](structure.drawio.svg)




#### MONGO CLUSTER AUTHENTICATION
Following are the general mongo cluster authentication instructions.
Everything has been done in the repo and user does not need to execute following instructions.
If user want to reconfigure some things, then these instructions are helpful

1) Generate keyfile with permissions

```
openssl rand -base64 741 > cnf/key.file
chmod 600 key.file
chown 999 key.file 
```

2) Copy mongod.conf.orig to cnf/mongod.conf from any mongo docker container.
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
in above script:
we have added admin user with username "root" and password "123456"

Start containers with auth
```
sh startContainersWithAuth.sh
```

