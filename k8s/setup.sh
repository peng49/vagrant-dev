#! /bin/bash
# 设置时区
sudo timedatectl set-timezone Asia/Shanghai

sudo curl -L -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

#https://www.jianshu.com/p/2206cb265247
sudo sed -ri 's/cloud.aliyuncs/aliyun/g' /etc/yum.repos.d/CentOS-Base.repo
sudo sed -ri 's/aliyuncs.com/aliyun.com/g' /etc/yum.repos.d/CentOS-Base.repo

sudo yum clean all && sudo yum makecache

# ssh允许密码登录
sudo sed -ri 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
# 允许root用户ssh登录
sudo sed -ri 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config
sudo systemctl restart sshd

# install some tools
sudo yum install -y vim telnet bind-utils wget


# install docker
curl -fsSL get.docker.com -o get-docker.sh
sh get-docker.sh

if [ ! "$(getent group docker)" ];
then 
    sudo groupadd docker;
else
    echo "docker user group already exists"
fi

sudo gpasswd -a $USER docker
sudo systemctl restart docker

# 设置daemon.json文件
sudo touch /etc/docker/daemon.json
sudo bash -c 'cat <<EOF > /etc/docker/daemon.json
{
        "registry-mirrors": [
                "https://ustc-edu-cn.mirror.aliyuncs.com",
                "https://xx4bwyg2.mirror.aliyuncs.com",
                "http://hub-mirror.c.163.com"
        ],
        "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF'
sudo systemctl restart docker

rm -rf get-docker.sh

# open password auth for backup if ssh key doesn't work, bydefault, username=vagrant password=vagrant
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo systemctl restart sshd

sudo bash -c 'cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF'

# 也可以尝试国内的源 http://ljchen.net/2018/10/23/%E5%9F%BA%E4%BA%8E%E9%98%BF%E9%87%8C%E4%BA%91%E9%95%9C%E5%83%8F%E7%AB%99%E5%AE%89%E8%A3%85kubernetes/

sudo setenforce 0

# install kubeadm, kubectl, and kubelet.
sudo yum install -y kubelet kubeadm kubectl

sudo bash -c 'cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward=1
EOF'

sudo bash -c 'cat <<EOF >  /etc/sysconfig/kubelet
KUBELET_EXTRA_ARGS="--fail-swap-on=false --cgroup-driver=systemd"
EOF'

sudo sysctl --system

sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo swapoff -a

# 永久关闭swap分区
sudo sed -ri 's/.*swap.*/#&/' /etc/fstab

systemctl enable docker.service
systemctl enable kubelet.service

sudo bash -c 'cat <<EOF >  /tmp/local.sh
for name in \`kubeadm config images list\`; do
  image=\${name//*\//}
  docker pull peng49/\$image
  docker tag peng49/\$image \$name
  docker rmi peng49/\$image
done;
EOF'

sudo sh /tmp/local.sh