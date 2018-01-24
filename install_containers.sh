#!/bin/bash
docker build -t client_app ./docker_images/python_client
docker build -t selenium_sinatra_firefox ./docker_images/selenium_sinatra_firefox
