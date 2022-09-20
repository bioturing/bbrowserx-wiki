#! /bin/bash

set -e

echo "Your Linux distribution [rhel, ubuntu]: "
read LINUX_DIST
if [ -z "$LINUX_DIST" ] || [ "$LINUX_DIST" != "ubuntu" ]; then
    bash ./docker/ubuntu.sh
else
    bash ./docker/rhel.sh
fi