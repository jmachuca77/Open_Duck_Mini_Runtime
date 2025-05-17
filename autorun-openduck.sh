#!/bin/bash

#Your controller MAC address
CONTROLLER="24:A6:FA:5C:84:CA"

#Wait for controller to connect
until bluetoothctl info "$CONTROLLER" | grep -q "Connected: yes"; do
    echo "Waiting for controller to connect..."
    sleep 5
done

echo "Controller connected, starting script..."
source /home/jaime/.virtualenvs/open-duck-mini-runtime/bin/activate

#Run your Python script
pushd /home/jaime/
./run.sh
