#!/bin/bash

docker build -f Dockerfile.cinnamon -t ubuntu-vm .
docker run -p 3389:3389 -p 5902:5902 -p 8096:8096 -d --name ubuntu-vm -ti ubuntu-vm

docker build -f Dockerfile.cinnamon -t ubuntu-vm2 .
docker run -p 3390:3389 -p 5903:5902 -p 8097:8096 -d --name ubuntu-vm2 -ti ubuntu-vm2
