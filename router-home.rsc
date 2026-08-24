# ==============================================
# MikroTik Lab: Базовая настройка домашнего роутера
# Автор: Ivankhvat
# Дата: 24.08.26
# Версия RouterOS: 7.21.5
# ==============================================
# Задача: Настроить CHR как шлюз для локальной сети
# Топология: ether1 (WAN) -> Интернет, ether2 (LAN) -> Host-Only
# ==============================================

# 1. Создаем бридж для локальной сети
/interface bridge
add name=bridge-lan

# 2. Добавляем порт ether2 в бридж
/interface bridge port
add bridge=bridge-lan interface=ether2

# 3. Назначаем IP-адрес шлюза для локальной сети
/ip address
add address=192.168.56.2/24 interface=bridge-lan

# 4. Настраиваем DHCP-сервер для раздачи адресов
/ip pool
add name=pool-lan ranges=192.168.56.100-192.168.56.200

/ip dhcp-server network
add address=192.168.56.0/24 gateway=192.168.56.2 dns-server=8.8.8.8

/ip dhcp-server
add name=dhcp-lan interface=bridge-lan address-pool=pool-lan disabled=no

# 5. Включаем NAT (Masquerade) для выхода в интернет
/ip firewall nat
add chain=srcnat out-interface=ether1 action=masquerade

# 6. (Опционально) Дадим роутеру имя
/system identity set name=MikroTik-CHR-Lab

print "Базовая настройка завершена!"