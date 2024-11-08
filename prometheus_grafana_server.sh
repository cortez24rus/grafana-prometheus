#!/bin/bash

sudo apt-get install -y apt-transport-https software-properties-common wget

# Prometheus
# Получаем ссылку на последнюю версию
latest_url=$(curl -s https://api.github.com/repos/prometheus/prometheus/releases/latest | grep "browser_download_url.*linux-amd64.tar.gz" | cut -d '"' -f 4)

wget -O prometheus_latest.tar.gz "$latest_url"
tar xvf prometheus_latest.tar.gz
rm prometheus_latest.tar.gz

sudo mv node_exporter-* node_exporter
chmod +x node_exporter/node_exporter
sudo mv node_exporter/node_exporter /usr/bin/
rm -Rvf node_exporter/

# Путь к файлу конфигурации Prometheus
CONFIG_FILE="/root/prometheus/prometheus.yml"

# Запрос на ввод нового хоста
read -p "Введите новый хост (в формате IP:PORT): " new_host

# Проверка, что введен корректный формат хоста
if [[ ! $new_host =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+$ ]]; then
  echo "Ошибка: введите хост в формате IP:PORT."
  exit 1
fi

# Добавление нового хоста в файл конфигурации
if grep -q "targets:" "$CONFIG_FILE"; then
  # Добавляем новый хост в строку targets через запятую
  sed -i "/targets: \[/ s/\]/, '$new_host']/g" "$CONFIG_FILE"
  echo "Хост $new_host добавлен в targets."
else
  echo "Ошибка: не найдена строка 'targets:' в $CONFIG_FILE."
fi

chmod +x /root/prometheus/prometheus
sudo tee /etc/systemd/system/prometheusd.service > /dev/null <<EOF
[Unit]
Description=prometheus
After=network-online.target
[Service]
User=root
ExecStart=/root/prometheus/prometheus --config.file="/root/prometheus/prometheus.yml"
Restart=always 
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable prometheusd
sudo systemctl restart prometheusd


# Grafana
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
sudo apt-get update && sudo apt-get install grafana -y

sudo systemctl daemon-reload && sudo systemctl enable grafana-server && sudo systemctl restart grafana-server
sudo ufw allow 3000
