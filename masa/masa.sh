# если возникает ошибка "connection refuse" то сделать следующее:
# remove Masa node
sudo systemctl stop masad
sudo systemctl disable masad
sudo rm -rf /etc/systemd/system/masad.service
sudo rm -rf /root/masa-node-v1.0
sudo rm -rf ~/masa-node-v1.0
sudo rm -rf /home/masa/masa-node-v1.0

