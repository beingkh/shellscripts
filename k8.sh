#!/bin/bash
# Initialize Master
sudo kubeadm init --pod-network-cidr=192.168.0.0/16

# Setup local kubeconfig
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Calico Network Plugin
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/custom-resources.yaml

echo "----------------------------------------"
echo "Master initialized. Copy the 'kubeadm join' command below and run it on your worker nodes."
echo "----------------------------------------"