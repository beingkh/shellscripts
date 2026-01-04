sudo swapoff -a
sudo yum install docker -y
sudo systemctl enable --now docker.service
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.35/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.35/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

sudo yum install -y kubelet kubeadm kubectl --setopt=disable_excludes=kubernetes
sudo systemctl start kubelet.service
sudo systemctl enable kubelet.service

# Create cluster
sudo kubeadm init 

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Calico Network Plugin
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.31.3/manifests/calico.yaml -O

# /etc/hosts - add host ips
# vim ~/.bashrc -- alias kubectl='kubectl --kubeconfig=/etc/kubernetes/admin.conf'