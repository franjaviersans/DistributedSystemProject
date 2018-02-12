#!/bin/bash -v
if [ $# != 1 ]; then
	echo "ERROR >>>> You have to set the number of server containers to start"
else
	i="0"
	
	docker network create mynet
	#erase servers and databases file
	rm servers.txt
	rm databases.txt

	while [ $i -lt $1 ]; do
		portDB=$[27017+$i]
		docker run -d --name db$i --net mynet -p $[portDB]:27017 -v $(pwd)/db$i:/data/db$i mongo
		
		portSinatra=$[3838+$i]
		portSelenium=$[3333+$i]
		
		docker run -d --name seleniumserver$i --net mynet -p $[portSinatra]:80  -p $[portSelenium]:4444 -v $(pwd):/usr/src/app --shm-size=2g -e MAIN_APP_FILE=./docker_images/selenium_sinatra_firefox/serverRest.rb -e DBDNS=db$i selenium_sinatra_firefox

		#print to servers file
		echo seleniumserver$i >> "servers.txt"
		echo db$i >> "databases.txt"
		
		i=$[$i+1]
	done

	#copy the list of servers to the client local folder, so it can access it
	cp servers.txt ./docker_images/python_client 
fi