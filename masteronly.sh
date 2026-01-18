#!/bin/bash
set -e

kubeadm init \
  --cri-socket=unix:///run/containerd/containerd.sock \
  --pod-network-cidr=192.168.0.0/16

mkdir -p $HOME/.kube
cp /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.2/manifests/calico.yaml
