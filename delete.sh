#!/bin/bash

sudo docker compose down -v

sudo userdel nextcloud
sudo userdel ddclient
sudo userdel nginx
sudo userdel transmission
sudo userdel plex
sudo groupdel mediacenter

sudo rm -rf $1
sudo rm -rf $2
