#! /bin/bash

set -e

echo "Your Linux distribution [rhel, ubuntu]: "
read LINUX_DIST
if [ -z "$LINUX_DIST" ] || [ "$LINUX_DIST" != "ubuntu" ]; then
    bash ./docker/rhel.sh
else
    bash ./docker/ubuntu.sh
fi