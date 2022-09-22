#! /bin/bash

set -e

read -s -p "Your Linux distribution [rhel, ubuntu]: " LINUX_DIST

if [ -z "$LINUX_DIST" ] || [ "$LINUX_DIST" != "ubuntu" ]; then
    bash ./docker/rhel.sh
else
    bash ./docker/ubuntu.sh
fi