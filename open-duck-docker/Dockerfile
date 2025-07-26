FROM arm64v8/ros:jazzy-perception
ENV DEBIAN_FRONTEND=noninteractive

# 1) add Deadsnakes PPA and pull in 3.11 + venv support
RUN apt-get update \
 && apt-get install -y --no-install-recommends software-properties-common \
 && apt-get install -y --no-install-recommends python3-pip \
 && apt-get install -y --no-install-recommends \
      ros-$ROS_DISTRO-rviz2 \
      ros-$ROS_DISTRO-foxglove-bridge \
      ros-$ROS_DISTRO-joint-state-publisher \
      ros-$ROS_DISTRO-joint-state-publisher-gui \
      ros-$ROS_DISTRO-bno055 \
      ros-$ROS_DISTRO-teleop-twist-keyboard \
      ros-$ROS_DISTRO-teleop-twist-joy \
      build-essential \
 && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      python3-pip \
      python3-venv \
      python3-empy \
      python3-catkin-pkg-modules \
 && rm -rf /var/lib/apt/lists/*

# need to install /opt/open-duck-mini-runtime/bin/python3 -m pip install catkin_pkg
# need to install empy
# build git clone -b $ROS_DISTRO https://github.com/ros2/rclpy.git
# git clone -b $ROS_DISTRO https://github.com/ros2/rcl.git
# git clone -b $ROS_DISTRO https://github.com/ros2/rcutils.git
# from source, remember to do a rosdep install

# RUN pip3 install --no-cache-dir \
#       --upgrade pip
# 2) Create a virtualenv under /opt/venv and put it first on PATH
RUN python3 -m venv /opt/venv \
 && /opt/venv/bin/pip install --upgrade pip \
 && /opt/venv/bin/pip install catkin_pkg

ENV VIRTUAL_ENV=/opt/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# 3) Now pip works un-protected. Install your runtime package & lgpio
RUN git clone --branch v2 https://github.com/apirrone/Open_Duck_Mini_Runtime \
 && cd Open_Duck_Mini_Runtime \
 && pip install -e . lgpio \
 && /opt/venv/bin/pip install PyYAML

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    nano \
 && rm -rf /var/lib/apt/lists/*

RUN /opt/venv/bin/pip install empy \
 && /opt/venv/bin/pip install lark-parser

SHELL ["/bin/bash", "-c"]

RUN mkdir -p /bdx_ws/src \
 && cd /bdx_ws/src \
 && git clone https://github.com/jmachuca77/open_duck_mini_description \
 && git clone https://github.com/jmachuca77/joystick_drivers 

RUN source /opt/ros/jazzy/setup.bash \
 && cd /bdx_ws \
 && colcon build --packages-select open_duck_mini_description joy

COPY ../checkpoints/ /root/checkpoints/
COPY ./inputrc /root/.inputrc
COPY ./bashrc /root/.bashrc
COPY ./duck_config.json /root/duck_config.json
COPY ./ros_entrypoint.sh /ros_entrypoint.sh
ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
