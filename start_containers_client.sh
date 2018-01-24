#!/bin/bash
docker run -it --rm  --net mynet  --name running_client_app client_app https://github.com/SeleniumHQ/selenium/wiki/Ruby-Bindings github.com 5

