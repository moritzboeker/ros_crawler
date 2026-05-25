#! /usr/bin/bash

SCRIPTS_BASE_DIR=$(realpath "$(dirname "$BASH_SOURCE[0]")")
WS_ROOT="${SCRIPTS_BASE_DIR}/.."

echo "Sourcing ROS install space and python venv"

source "${WS_ROOT}/install/setup.bash"
source "${WS_ROOT}/.venv/bin/activate"
PYTHONLIBDIR=$(python3 -c 'import sys; print(f"python{sys.version_info.major}.{sys.version_info.minor}")'); \
export PYTHONPATH="${WS_ROOT}/.venv/lib/${PYTHONLIBDIR}/site-packages/":$PYTHONPATH

