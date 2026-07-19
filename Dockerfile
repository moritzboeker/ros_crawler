FROM ros:jazzy

# Standalone YDLidar SDK, required by ydlidar_ros2_driver (find_package(ydlidar_sdk))
ARG YDLIDAR_SDK_VERSION=V1.2.7

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        git \
        python3-pip \
    && rm -rf /var/lib/apt/lists/* \
    && git clone --depth 1 --branch "${YDLIDAR_SDK_VERSION}" \
        https://github.com/YDLIDAR/YDLidar-SDK.git /tmp/YDLidar-SDK \
    && cmake -S /tmp/YDLidar-SDK -B /tmp/YDLidar-SDK/build -DCMAKE_BUILD_TYPE=Release \
    && cmake --build /tmp/YDLidar-SDK/build -j"$(nproc)" \
    && cmake --install /tmp/YDLidar-SDK/build \
    && ldconfig \
    && rm -rf /tmp/YDLidar-SDK

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
