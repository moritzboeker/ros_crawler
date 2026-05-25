#!/usr/bin/bash

set -e

SCRIPTS_BASE_DIR=$(realpath "$(dirname "$BASH_SOURCE[0]")")
WS_ROOT="${SCRIPTS_BASE_DIR}/.."

cd ${WS_ROOT}

echo "Creating python venv in $(pwd)"

python3 -m venv .venv --clear
touch .venv/COLCON_IGNORE
source .venv/bin/activate
pip3 install --upgrade pip

cd ${SCRIPTS_BASE_DIR}
pip3 install -r requirements.txt
deactivate # deactivate virtualenv for colcon build

