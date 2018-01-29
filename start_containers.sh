#!/bin/bash -v
docker network create mynet
docker run -d --name db1 --net mynet -p 27017:27017 -v $(pwd)/data1:/data/db mongo
docker run -d --name db2 --net mynet -p 27018:27017 -v $(pwd)/data2:/data/db mongo
docker run -d --name seleniumserver1 --net mynet -p 3838:80  -p 3333:4444 -v $(pwd):/usr/src/app --shm-size=2g -e MAIN_APP_FILE=./docker_images/selenium_sinatra_firefox/serverRest.rb -e DBDNS=db1 selenium_sinatra_firefox
docker run -d --name seleniumserver2 --net mynet -p 2929:80  -p 5555:4444 -v $(pwd):/usr/src/app --shm-size=2g -e MAIN_APP_FILE=./docker_images/selenium_sinatra_firefox/serverRest.rb -e DBDNS=db2 selenium_sinatra_firefox