# ros_crawler
Turn a remote controlled car into an autonomous robot via a raspberry pi 4 and ROS2 Jazzy.
Further details: [https://www.moritzboeker.de/](https://www.moritzboeker.de/2022/08/ros-raspi-car/)

## Run in Docker

The image `ghcr.io/moritzboeker/ros_raspi_car:jazzy-v1.0.0` (linux/arm64) contains the YDLidar SDK and `foxglove_bridge`. On start it runs `ros2 launch bringup bringup.py`.

### One-time setup on the Raspberry Pi

```bash
# stable /dev/ydlidar symlink for the lidar's CP210x USB-UART bridge
sudo cp docker/99-crawler.rules /etc/udev/rules.d/
sudo udevadm control --reload && sudo udevadm trigger

# get the compose file (or copy docker-compose.yml manually)
mkdir -p ~/crawler && cp docker-compose.yml ~/crawler/
```

### Run / update

```bash
cd ~/crawler
docker compose pull   # fetch the latest image
docker compose up -d  # start; restarts automatically on boot (restart: unless-stopped)
docker compose logs -f
```

The container uses host networking, so topics are visible on the LAN via DDS (matching `ROS_DOMAIN_ID`). For visualization, connect [Lichtblick](https://github.com/lichtblick-suite/lichtblick) on your laptop to `ws://<pi-ip>:8765` (Foxglove WebSocket).

### Build the image

CI (`.github/workflows/docker.yml`) builds and pushes the image on every push to `main` using a native arm64 runner. To build and push manually from an x86 machine:

```bash
docker login ghcr.io                  # PAT with write:packages
docker buildx build --platform linux/arm64 -t ghcr.io/moritzboeker/ros_raspi_car:jazzy --push .
```

### Troubleshooting:
1. Ydlidar: In case the lidar does not turn, you might need to connect the power USB plug of the lidar into a separate USB port providing enough power other than the Raspberry Pi. Powerbanks usually provide enough current, the RaspberryPi itself doesn't.


