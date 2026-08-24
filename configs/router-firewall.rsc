# ==============================================
# MikroTik Lab: Базовая настройка Firewall (Безопасность)
# Автор: Ivankhvat
# Дата: 24.08.26
# Версия RouterOS: 7.24
# ==============================================
# Задача: Защитить роутер от атак из интернета (WAN)
# Топология:
#   ether1 (WAN)  -> Интернет (Небезопасная зона)
#   ether2 (LAN)  -> Локальная сеть (Доверенная зона)
# Логика: "Запрещено всё, что не разрешено явно"
# ==============================================

# --------------------------------------------------
# Блок 1: Базовые правила обработки соединений
# --------------------------------------------------
# Правило Established/Related:
# Разрешаем трафик, который является ответом на наши запросы
# (Если мы не разрешим это первым, интернет перестанет работать)
/ip firewall filter
add chain=input connection-state=established,related action=accept comment="[1] Accept Established/Related (Input)"
add chain=forward connection-state=established,related action=accept comment="[2] Accept Established/Related (Forward)"

# Правило Invalid:
# Отбрасываем "мусорные" пакеты, которые не принадлежат ни одному соединению
add chain=input connection-state=invalid action=drop comment="[3] Drop Invalid (Input)"
add chain=forward connection-state=invalid action=drop comment="[4] Drop Invalid (Forward)"

# --------------------------------------------------
# Блок 2: Защита самого роутера (Цепочка Input)
# --------------------------------------------------
# Мы разрешаем доступ к роутеру (WinBox, SSH, Ping) только из локальной сети.
# Все попытки подключиться к роутеру из интернета (ether1) блокируются.

# Разрешаем всё общение из локальной сети к роутеру
add chain=input in-interface=bridge-lan action=accept comment="[5] Allow LAN to Router (Input)"

# Разрешаем ICMP (Ping) из локальной сети (для диагностики)
add chain=input protocol=icmp in-interface=bridge-lan action=accept comment="[6] Allow Ping from LAN"

# ЗАПРЕЩАЕМ всё, что приходит из интернета (WAN) и адресовано самому роутеру
# Это ключевая защита от попыток подбора пароля и сканирования портов
add chain=input in-interface=ether1 action=drop comment="[7] DROP ALL FROM WAN TO ROUTER"

# --------------------------------------------------
# Блок 3: Обработка трафика (Цепочка Forward)
# --------------------------------------------------
# Здесь решается, кого пропускать "через" роутер в другие сети.

# Разрешаем пользователям из локальной сети выходить в интернет (в WAN)
add chain=forward in-interface=bridge-lan out-interface=ether1 action=accept comment="[8] Allow LAN to Internet (Forward)"

# --------------------------------------------------
# Блок 4: Финал (Drop All)
# --------------------------------------------------
# Страховка на случай, если мы что-то не учли или забыли правило.
# Всё, что не подошло под разрешающие правила выше, уничтожается.
add chain=input action=drop comment="[9] DROP ALL OTHER INPUT"
add chain=forward action=drop comment="[10] DROP ALL OTHER FORWARD"

# --------------------------------------------------
# Логирование (Опционально, чтобы видеть атаки)
# --------------------------------------------------
# Если хотите видеть, как часто вас пытаются атаковать, раскомментируйте
# следующую строку. Она будет логировать первые 10 пакетов в секунду.
# add chain=input action=log log-prefix="FIREWALL_DROP" limit=10/s,5m

print "Конфигурация Firewall применена!"
