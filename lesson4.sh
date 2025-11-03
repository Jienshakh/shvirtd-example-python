#!/bin/bash

cd /opt
sudo mkdir $USER
sudo chown -R $USER $USER
cd $USER
git clone git@github.com:Jienshakh/shvirtd-example-python.git
cd shvirtd-example-python
docker compose up -d
docker ps

