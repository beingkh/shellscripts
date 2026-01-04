#!/bin/bash

sudo kubeadm init 
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Calico Network Plugin
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.31.3/manifests/calico.yaml -O
