# Get Private IP
IPADDR=$(hostname -I | awk '{print $1}')

# Initialize Cluster
sudo kubeadm init --apiserver-advertise-address=$IPADDR --pod-network-cidr=192.168.0.0/16 --ignore-preflight-errors=NumCPU,Mem

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Network Plugin (Run on MASTER Only)
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/custom-resources.yaml