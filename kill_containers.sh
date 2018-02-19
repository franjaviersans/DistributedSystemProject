#!/bin/bash -v

#remove serverts
while IFS='' read -r line || [[ -n "$line" ]]; do
    docker rm -f $line
done < "servers.txt"

#remove databases
while IFS='' read -r line || [[ -n "$line" ]]; do
    docker rm -f $line
    rm -Rf $line
done < "databases.txt"

#remove client, just in case
docker rm -f running_client_app

#remove network
docker network rm mynet

#remove files
rm servers.txt
rm databases.txt
rm ./docker_images/python_client/servers.txt
