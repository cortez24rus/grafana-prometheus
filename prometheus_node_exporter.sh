#!/bin/bash

# Получаем ссылку на последнюю версию
latest_url=$(curl -s https://api.github.com/repos/prometheus/node_exporter/releases/latest | grep "browser_download_url.*linux-amd64.tar.gz" | cut -d '"' -f 4)
wget -O node_exporter_latest.tar.gz "$latest_url"
tar xvf node_exporter_latest.tar.gz
rm node_exporter_latest.tar.gz

mv node_exporter-* node_exporter
chmod +x node_exporter/node_exporter
mv node_exporter/node_exporter /usr/bin/
rm -Rvf node_exporter/

cat > /etc/systemd/system/exporterd.service <<EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=root
ExecStart=/usr/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable exporterd.service
systemctl start exporterd.service
