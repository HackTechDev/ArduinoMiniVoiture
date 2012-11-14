#!/bin/sh

# Pour Ubuntu 9.10

sudo cp interfaces.static /etc/network/interfaces
sudo /etc/init.d/networking restart
ifconfig
