#!/bin/sh

# Pour Ubuntu 9.10

sudo cp interfaces.dynamic /etc/network/interfaces
sudo /etc/init.d/networking restart
ifconfig
