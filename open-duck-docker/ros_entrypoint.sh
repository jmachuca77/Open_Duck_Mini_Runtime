#!/bin/bash
set -e
# source the ROS 2 setup
source /opt/ros/jazzy/setup.bash
echo "Sourcing bdx_ws"
source /bdx_ws/install/setup.bash
# then exec whatever the user passed in
#ros2 launch open_duck_mini_description display.launch.py 
exec "$@"
