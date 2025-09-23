#! /bin/bash
apt-get -y update
apt-get -y install ca-certificates curl gnupg
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get -y update
apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

#kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin

# Azure cli
# apt-get -y install ca-certificates curl apt-transport-https lsb-release gnupg
# mkdir -p /etc/apt/keyrings
# curl -sLS https://packages.microsoft.com/keys/microsoft.asc |  \
#     gpg --dearmor |  \
#     tee /etc/apt/keyrings/microsoft.gpg > /dev/null
# sudo chmod go+r /etc/apt/keyrings/microsoft.gpg
# AZ_DIST=$(lsb_release -cs)
# echo "deb [arch=`dpkg --print-architecture` signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $AZ_DIST main" | \
#     sudo tee /etc/apt/sources.list.d/azure-cli.list

# apt-get update -y
# apt-get install -y azure-cli


# Python
apt install python3.11 pip -y
pip install Flask

apt install git


cd /home/azureadm

git clone https://github.com/pzsolt72/oe-kubernetes.git

chown -R azureadm /home/azureadm/oe-kubernetes
