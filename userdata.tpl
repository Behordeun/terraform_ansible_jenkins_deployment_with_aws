#!/bin/bash

sudo hostnamectl set-hostname ${new_hostname} &&

sudo apt-get install -y apt-transport-https software-properties-common wget &&

wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add - &&

echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list &&

sudo apt-get update &&

sudo apt-get install grafana &&

sudo systemctl start grafana-server &&

sudo systemctl enable grafana-server.service

#!/bin/bash

set -e

# Set hostname
#sudo hostnamectl set-hostname ${"$new_hostname"}

# Install required packages
#sudo apt-get -y update
#sudo apt-get -y install -y apt-transport-https software-properties-common wget

# Add Grafana GPG key and repository
#wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
#echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list

# Install Grafana
#sudo apt-get -y update
#sudo apt-get -y install -y grafana

# Enable and start Grafana service
#sudo systemctl enable grafana-server
#sudo systemctl start grafana-server
