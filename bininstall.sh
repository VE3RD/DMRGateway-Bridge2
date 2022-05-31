#!/bin/bash
sudo mount -o remount,rw /
dmrgateway.service stop
cp DMRGateway /usr/local/bin
dmrgateway.service start


