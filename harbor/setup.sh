#! /bin/bash
# 设置时区
sudo timedatectl set-timezone Asia/Shanghai

sudo curl -L -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

#https://www.jianshu.com/p/2206cb265247
sudo sed -ri 's/cloud.aliyuncs/aliyun/g' /etc/yum.repos.d/CentOS-Base.repo
sudo sed -ri 's/aliyuncs.com/aliyun.com/g' /etc/yum.repos.d/CentOS-Base.repo

sudo yum clean all && sudo yum makecache

# 安装最新版本的docker,harbor 依赖docker构建
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine

sudo yum install -y yum-utils
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

sudo yum install -y docker-ce docker-ce-cli containerd.io

# 安装 docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

sudo systemctl start docker
sudo systemctl enable docker

# 设置daemon.json文件
sudo touch /etc/docker/daemon.json
sudo bash -c 'cat <<EOF > /etc/docker/daemon.json
{
        "registry-mirrors": [
                "https://ustc-edu-cn.mirror.aliyuncs.com",
                "https://xx4bwyg2.mirror.aliyuncs.com",
                "http://hub-mirror.c.163.com"
        ]
}
EOF'
sudo systemctl restart docker

# 下载harbor在线安装包
sudo curl https://github.com/goharbor/harbor/releases/download/v1.10.10/harbor-online-installer-v1.10.10.tgz -L -o harbor-online-installer-v1.10.10.tgz \
 && sudo tar -xzvf harbor-online-installer-v1.10.10.tgz -C /usr/local/

# 覆盖配置文件并执行安装脚本
sudo mv -f /usr/local/harbor/harbor.yml /usr/local/harbor/harbor.yml.old \
  && sudo cp -f /vagrant/harbor.yml /usr/local/harbor/harbor.yml \
  && sudo sh /usr/local/harbor/install.sh







