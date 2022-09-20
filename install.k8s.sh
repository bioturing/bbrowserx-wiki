#! /bin/bash

set -e

echo "Your K8S engines [vanilla, microk8s]: "
read K8S_DIST
if [ -z "$K8S_DIST" ] || [ "$K8S_DIST" != "microk8s" ]; then
    bash ./k8s/vanillak8s.install.sh
else
    bash ./k8s/microk8s.install.sh
fi