#!/bin/bash -v
docker rm -f seleniumserver1
docker rm -f seleniumserver2
docker rm -f db1
docker rm -f db2
docker rm -f running_client_app
docker network rm mynet
rm -Rf data1
rm -Rf data2