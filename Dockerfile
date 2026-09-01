FROM ros:jazzy

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Sensor library for the SparkFun OTOS, not resolvable via rosdep
RUN pip3 install --no-cache-dir --break-system-packages sparkfun-qwiic-otos smbus2

WORKDIR /ws
COPY . src/ros_crawler

RUN apt-get update \
    && rosdep update --rosdistro "${ROS_DISTRO}" \
    && rosdep install --from-paths src --ignore-src -y --rosdistro "${ROS_DISTRO}" \
    && rm -rf /var/lib/apt/lists/*

RUN . "/opt/ros/${ROS_DISTRO}/setup.sh" \
    && colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release

COPY --chmod=755 docker/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["ros2", "launch", "bringup", "bringup.py"]
