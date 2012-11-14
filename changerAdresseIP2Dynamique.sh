#!/bin/sh

sudo cp interfaces.dynamic /etc/network/interfaces
sudo /etc/init.d/networking restart
ifconfig
