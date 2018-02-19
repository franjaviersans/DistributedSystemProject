#!/bin/bash -v
docker run -it --rm  --net mynet  --name running_client_app  -v $(pwd)/docker_images/python_client/:/usr/src/app -e MAIN_APP_FILE=./client.py client_app links.txt github.com 5 servers.txt

