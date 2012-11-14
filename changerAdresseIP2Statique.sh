#!/bin/sh

sudo cp interfaces.static /etc/network/interfaces
sudo /etc/init.d/networking restart
ifconfig
