#!/bin/bash


IMAGES_POOL="/kvm-pool/images/"

#cloud_images

# mirror https://cloud.centos.org/centos/7/images/
CENTOS_URL="https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud-1907.qcow2"
CENTOS_IMAGE=${IMAGES_POOL}`echo $CENTOS_URL | tr "/" "\n" | tail -n1`

# mirror https://cloud-images.ubuntu.com/releases/
UBUNTU_URL="https://cloud-images.ubuntu.com/releases/bionic/release/ubuntu-18.04-server-cloudimg-amd64.img"
UBUNTU_IMAGE=${IMAGES_POOL}`echo $UBUNTU_URL| tr "/" "\n" | tail -n1`



if [ -f "$CENTOS_IMAGE" ]; then
    echo $CENTOS_IMAGE
    echo уже существует
else
    echo download $CENTOS_IMAGE
    curl $CENTOS_URL --output $CENTOS_IMAGE 
fi


if [ -f "$UBUNTU_IMAGE" ]; then
    echo $UBUNTU_IMAGE
    echo уже существует
else
    echo download $UBUNTU_IMAGE
    curl $UBUNTU_URL --output $UBUNTU_IMAGE
fi
