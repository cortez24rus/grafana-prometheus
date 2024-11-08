#!/bin/bash

wget https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz
tar xvf node_exporter-1.8.2.linux-amd64.tar.gz

rm node_exporter-1.8.2.linux-amd64.tar.gz
sudo mv node_exporter-1.8.2.linux-amd64 node_exporter
chmod +x node_exporter/node_exporter
sudo mv node_exporter/node_exporter /usr/bin/
rm -Rvf node_exporter/

sudo tee /etc/systemd/system/exporterd.service > /dev/null <<EOF
[Unit]
Description=Node Exporter
After=network.target
[Service]
User=root
ExecStart=/usr/bin/node_exporter
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable exporterd.service
sudo systemctl start exporterd.service

ufw allow 9100
