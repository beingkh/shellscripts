#!/bin/bash

echo "----------------------------------------------------"
echo "🚀 Starting Kubernetes Setup for Amazon Linux 2023..."
echo "----------------------------------------------------"

# --- 1. SYSTEM PREP ---
echo "🔧 Disabling Swap..."
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

echo "🔧 Setting SELinux to Permissive..."
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

echo "🔧 Loading Kernel Modules..."
cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

echo "🔧 Tuning Network Parameters..."
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system

# --- 2. CONTAINER RUNTIME (Containerd) ---
echo "📦 Installing Containerd..."
dnf install -y containerd
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml

# CRITICAL FIX: Enable SystemdCgroup (Fixes "Pod Sandbox Changed" error)
echo "⚙️  Configuring SystemdCgroup..."
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

systemctl enable --now containerd

# --- 3. KUBERNETES TOOLS ---
echo "📦 Adding Kubernetes Repo..."
cat <<EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

echo "📦 Installing Kubeadm, Kubelet, Kubectl & Traffic Control..."
# iproute-tc is mandatory for Amazon Linux 2023
dnf install -y kubelet kubeadm kubectl iproute-tc --disableexcludes=kubernetes

echo "🚀 Enabling Kubelet..."
systemctl enable --now kubelet

echo "----------------------------------------------------"
echo "✅ Installation Complete! Ready for 'kubeadm init' or 'kubeadm join'."
echo "----------------------------------------------------"