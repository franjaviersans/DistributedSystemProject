#!/bin/bash
docker network create mynet
docker run  -d  --name seleniumserver1 --net mynet -p 3838:80  -p 3333:4444 -v $(pwd):/usr/src/app --shm-size=2g -e MAIN_APP_FILE=./docker_images/selenium_sinatra_firefox/serverRest.rb selenium_sinatra_firefox
docker run  -d  --name seleniumserver2 --net mynet -p 2929:80  -p 5555:4444 -v $(pwd):/usr/src/app --shm-size=2g -e MAIN_APP_FILE=./docker_images/selenium_sinatra_firefox/serverRest.rb selenium_sinatra_firefox

