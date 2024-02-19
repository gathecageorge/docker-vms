#!/bin/bash

docker build -f Dockerfile.cinnamon -t ubuntu-vm .
docker run -p 3389:3389 -p 5902:5902 -p 8096:8096 -d --name ubuntu-vm -ti ubuntu-vm

docker build -f Dockerfile.xubuntu -t ubuntu-vm2 .
docker run -p 3390:3389 -p 5903:5902 -p 8097:8096 -d --name ubuntu-vm2 -ti ubuntu-vm2

docker build -f Dockerfile.mate -t ubuntu-vm3 .
docker run -p 3391:3389 -p 5904:5902 -p 8098:8096 -d --name ubuntu-vm3 -ti ubuntu-vm3

docker build -f Dockerfile_xserver.lubuntu -t ubuntu-vm4-xserver .
docker run -d --name ubuntu-vm4-xserver -e DISPLAY=host.docker.internal:0 -ti ubuntu-vm4-xserver

docker build -f Dockerfile_xserver.ubuntu -t ubuntu-vm5-xserver .
docker run -d --name ubuntu-vm5-xserver -ti ubuntu-vm5-xserver
