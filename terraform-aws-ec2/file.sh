#!/bin/bash

sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform
sudo touch ~/.bashrc
sudo terraform -install-autocomplete
sudo amazon-linux-extras install docker
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo chkconfig docker on
sudo yum install -y git
# DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
# mkdir -p $DOCKER_CONFIG/cli-plugins
# curl -SL https://github.com/docker/compose/releases/download/v2.6.1/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
# chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose
# sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
sudo curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
# curl -SL https://github.com/docker/compose/releases/download/v2.6.1/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
# sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
sudo systemctl enable docker
# echo "test" > test
runuser -l ec2-user -c "docker-compose up"