#! /bin/bash

set -e

_RED='\033[0;31m'
_GREEN='\033[0;32m'
_BLUE='\033[0;34m'
_NC='\033[0m' # No Color

echo -e "${_BLUE}BioTuring ecosystem VanillaK8S installation version${_NC} ${_GREEN}stable${_NC}\n"

read -s -p "Please input Bioturing's TOKEN: " BBTOKEN
if [ -z "$BBTOKEN" ]; then
    echo -e "${_RED}Can not empty BBTOKEN${_NC}\n"
    exit 1
fi

read -s -p "Please input your DOMAIN: " SVHOST
if [ -z "$SVHOST" ]; then
    echo -e "${_RED}Can not empty your domain${_NC}\n"
    exit 1
fi

read -s -p "Please input your admin name (admin): " ADMIN_USERNAME
if [ -z "$ADMIN_USERNAME" ]; then
    ADMIN_USERNAME="admin"
fi

read -s -p "Please input your admin password (turing2022): " ADMIN_PASSWORD
if [ -z "$ADMIN_PASSWORD" ]; then
    ADMIN_PASSWORD="turing2022"
fi

read -s -p "Please input BBrowserX's VERSION (1.0.11): " BBVERSION
if [ -z "$BBVERSION" ]; then
    BBVERSION="1.0.11"
fi

read -s -p "Please input APP-DATA PCV's size (5Gi): " APPDATA_PVC_SIZE
if [ -z "$APPDATA_PVC_SIZE" ]; then
    APPDATA_PVC_SIZE="5Gi"
fi

read -s -p "Please input USER-DATA PCV's size (5Gi): " USERDATA_PVC_SIZE
if [ -z "$USERDATA_PVC_SIZE" ]; then
    USERDATA_PVC_SIZE="5Gi"
fi

SSLCRT=""
SSLKEY=""
read -s -p "Use lets-encrypt SSL (must be public your domain), [y, n]: " USELETSENCRYPT
if [ -z "$USELETSENCRYPT" ] || [ "$USELETSENCRYPT" != "y" ]; then
    USELETSENCRYPT="false"

    read -s -p "Please input SSL_CRT file: " CRT_PATH
    if [ -z "$CRT_PATH" ]; then
        echo -e "${_RED}Can not empty SSL_CRT file${_NC}\n"
        exit 1
    fi
    
    if [[ -f $CRT_PATH ]]; then 
        SSLCRT=`base64 -w 0 ${CRT_PATH}`
    else
        echo -e "${_RED}Can not find: ${CRT_PATH}${_NC}\n"
        exit 1
    fi

    read -s -p "Please input SSL_KEY file: " KEY_PATH
    if [ -z "$KEY_PATH" ]; then
        echo -e "${_RED}Can not empty KEY_PATH file${_NC}\n"
        exit 1
    fi
    
    if [[ -f $CRT_PATH ]]; then 
        SSLKEY=`base64 -w 0 ${KEY_PATH}`
    else
        echo -e "${_RED}Can not find: ${KEY_PATH}${_NC}\n"
        exit 1
    fi
else
    USELETSENCRYPT="true"
fi

read -s -p "Please input K8S namespace (default): " K8S_NAMESPACE
if [ -z "$K8S_NAMESPACE" ]; then
    K8S_NAMESPACE=""
fi

echo -e "${_BLUE}Enable GPU operator${_NC}\n"
helm repo add nvidia https://helm.ngc.nvidia.com/nvidia
helm repo update
helm install --wait --generate-name nvidia/gpu-operator -n kube-system --set driver.enabled=false --set toolkit.enabled=false --debug

echo -e "${_BLUE}Add BioTuring Helm charts to K8S service${_NC}\n"
helm repo add bioturing https://registry.bioturing.com/charts/
helm repo update

echo -e "${_BLUE}Install BioTuring ecosystem to K8S service${_NC}\n"
if [ "$USELETSENCRYPT" == "true" ]; then
    if [ -z "$K8S_NAMESPACE" ]; then
        helm upgrade --install --set secret.data.bbtoken="${BBTOKEN}" \
            --set secret.data.domain="${SVHOST}" \
            --set secret.server.useletsencrypt="${USELETSENCRYPT}" \
            --set secret.admin.username="${ADMIN_USERNAME}" \
            --set secret.admin.password="${ADMIN_PASSWORD}" \
            --set persistence.dirs.user.size="${USERDATA_PVC_SIZE}" \
            --set persistence.dirs.app.size="${APPDATA_PVC_SIZE}" \
            bioturing bioturing/ecosystem --version ${BBVERSION}
    else
        helm upgrade --install --set secret.data.bbtoken="${BBTOKEN}" \
            --set secret.data.domain="${SVHOST}" \
            --set secret.server.useletsencrypt="${USELETSENCRYPT}" \
            --set secret.admin.username="${ADMIN_USERNAME}" \
            --set secret.admin.password="${ADMIN_PASSWORD}" \
            --set persistence.dirs.user.size="${USERDATA_PVC_SIZE}" \
            --set persistence.dirs.app.size="${APPDATA_PVC_SIZE}" \
            --namespace ${K8S_NAMESPACE} \
            bioturing bioturing/ecosystem --version ${BBVERSION} \
            --create-namespace
    fi
else
    if [ -z "$K8S_NAMESPACE" ]; then
        helm upgrade --install --set secret.data.bbtoken="${BBTOKEN}" \
            --set secret.data.domain="${SVHOST}" \
            --set secret.server.certificate="${SSLCRT}" \
            --set secret.server.key="${SSLKEY}" \
            --set secret.server.useletsencrypt="${USELETSENCRYPT}" \
            --set secret.admin.username="${ADMIN_USERNAME}" \
            --set secret.admin.password="${ADMIN_PASSWORD}" \
            --set persistence.dirs.user.size="${USERDATA_PVC_SIZE}" \
            --set persistence.dirs.app.size="${APPDATA_PVC_SIZE}" \
            bioturing bioturing/ecosystem --version ${BBVERSION}
    else
        helm upgrade --install --set secret.data.bbtoken="${BBTOKEN}" \
            --set secret.data.domain="${SVHOST}" \
            --set secret.server.certificate="${SSLCRT}" \
            --set secret.server.key="${SSLKEY}" \
            --set secret.server.useletsencrypt="${USELETSENCRYPT}" \
            --set secret.admin.username="${ADMIN_USERNAME}" \
            --set secret.admin.password="${ADMIN_PASSWORD}" \
            --set persistence.dirs.user.size="${USERDATA_PVC_SIZE}" \
            --set persistence.dirs.app.size="${APPDATA_PVC_SIZE}" \
            --namespace ${K8S_NAMESPACE} \
            bioturing bioturing/ecosystem --version ${BBVERSION} \
            --create-namespace
    fi
fi