#! /bin/bash

set -e

_RED='\033[0;31m'
_GREEN='\033[0;32m'
_BLUE='\033[0;34m'
_NC='\033[0m' # No Color

echo -e "${_BLUE}BioTuring ecosystem VanillaK8S installation version${_NC} ${_GREEN}stable${_NC}\n"

echo "Please input Bioturing's TOKEN: "
read BBTOKEN
if [ -z "$BBTOKEN" ]; then
    echo -e "${_RED}Can not empty BBTOKEN${_NC}\n"
    exit 1
fi

echo "Please input your DOMAIN: "
read SVHOST
if [ -z "$SVHOST" ]; then
    echo -e "${_RED}Can not empty your domain${_NC}\n"
    exit 1
fi

echo "Please input your admin name (admin): "
read ADMIN_USERNAME
if [ -z "$ADMIN_USERNAME" ]; then
    ADMIN_USERNAME="admin"
fi

echo "Please input your admin password (turing2022): "
read ADMIN_PASSWORD
if [ -z "$ADMIN_PASSWORD" ]; then
    ADMIN_PASSWORD="turing2022"
fi

echo "Please input BBrowserX's VERSION (1.0.11): "
read BBVERSION
if [ -z "$BBVERSION" ]; then
    BBVERSION="1.0.11"
fi

echo "Please input APP-DATA PCV's size (5Gi): "
read APPDATA_PVC_SIZE
if [ -z "$APPDATA_PVC_SIZE" ]; then
    APPDATA_PVC_SIZE="5Gi"
fi

echo "Please input USER-DATA PCV's size (5Gi): "
read USERDATA_PVC_SIZE
if [ -z "$USERDATA_PVC_SIZE" ]; then
    USERDATA_PVC_SIZE="5Gi"
fi

SSLCRT=""
SSLKEY=""
echo "Use lets-encrypt SSL (must be public your domain), [y, n]: "
read USELETSENCRYPT
if [ -z "$USELETSENCRYPT" ] || [ "$USELETSENCRYPT" != "y" ]; then
    USELETSENCRYPT="false"

    echo "Please input SSL_CRT file: "
    read CRT_PATH
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

    echo "Please input SSL_KEY file: "
    read KEY_PATH
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

echo -e "${_BLUE}Add BioTuring Helm charts to K8S service${_NC}\n"
helm repo add bioturing https://registry.bioturing.com/charts/
helm repo update

echo -e "${_BLUE}Install BioTuring ecosystem to K8S service${_NC}\n"
if [ "$USELETSENCRYPT" == "true" ]; then
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
        --set secret.server.certificate="${SSLCRT}" \
        --set secret.server.key="${SSLKEY}" \
        --set secret.server.useletsencrypt="${USELETSENCRYPT}" \
        --set secret.admin.username="${ADMIN_USERNAME}" \
        --set secret.admin.password="${ADMIN_PASSWORD}" \
        --set persistence.dirs.user.size="${USERDATA_PVC_SIZE}" \
        --set persistence.dirs.app.size="${APPDATA_PVC_SIZE}" \
        bioturing bioturing/ecosystem --version ${BBVERSION}
fi