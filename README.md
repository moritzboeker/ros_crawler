# ROS Crawler
Turn a remote controlled car into an autonomous robot via a raspberry pi 4 and ROS2 Jazzy.
Further details: [https://www.moritzboeker.de/](https://www.moritzboeker.de/2022/08/ros-raspi-car/)

## Parts
- Remote-controlled car: I used the [DF-4J - XXL Crawler](https://www.df-models.info/RC-Cars/BasicLine-XXL), because it's rather slow but powerful
- Raspberry Pi 4B or higher
- Odometry: [SparkFun Optical Tracking Odometry Sensor - PAA5160E1 (Qwiic)](https://www.sparkfun.com/sparkfun-optical-tracking-odometry-sensor-paa5160e1-qwiic.html)
- Laser Scanner: [YDLIDAR X2 360° 2D-LiDAR-Sensor](https://exp-tech.de/products/x2)
- Servo Driver: [16-Channel 12-bit PWM/Servo Driver - I2C interface - PCA9685](https://www.adafruit.com/product/815)

## Run in Docker

The image `ghcr.io/moritzboeker/ros_crawler:jazzy` (linux/arm64) contains the YDLidar SDK and `foxglove_bridge`. On start it runs `ros2 launch bringup bringup.py`.

### One-time setup on the Raspberry Pi

```bash
# stable /dev/ydlidar symlink for the lidar's CP210x USB-UART bridge
git clone --recursive --branch ros2 https://github.com/moritzboeker/ros_crawler.git ~/ros_crawler
cd ~/ros_crawler
sudo cp docker/99-crawler.rules /etc/udev/rules.d/
sudo udevadm control --reload && sudo udevadm trigger
```

### Run / update

```bash
cd ~/ros_crawler
docker compose pull   # fetch the latest image
docker compose up -d  # start; restarts automatically on boot (restart: unless-stopped)
docker compose logs -f
```

The container uses host networking, so topics are visible on the LAN via DDS (matching `ROS_DOMAIN_ID`). For visualization, connect [Lichtblick](https://github.com/lichtblick-suite/lichtblick) on your laptop to `ws://<pi-ip>:8765` (Foxglove WebSocket).

### Build the image manually

CI (`.github/workflows/docker.yml`) builds and pushes the image on every push to `main` using a native arm64 runner. To build and push manually from an x86 machine:

```bash
docker login ghcr.io                  # PAT with write:packages
docker buildx build --platform linux/arm64 -t ghcr.io/moritzboeker/ros_crawler:jazzy-test .
```

### Troubleshooting:
1. Ydlidar: In case the lidar does not turn, you might need to connect the power USB plug of the lidar into a separate USB port providing enough power other than the Raspberry Pi. Powerbanks usually provide enough current, the RaspberryPi itself doesn't.


