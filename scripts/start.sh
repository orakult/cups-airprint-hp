#!/bin/sh
set -e

# Копируем конфиги из /config если есть
[ -f /config/printers.conf ] && cp /config/printers.conf /etc/cups/printers.conf

# Создаём admin пользователя
CUPSADMIN=${CUPSADMIN:-admin}
CUPSPASSWORD=${CUPSPASSWORD:-admin}

# Создаём системного пользователя
useradd -M -s /usr/sbin/nologin "${CUPSADMIN}" 2>/dev/null || true

# Устанавливаем пароль через openssl + passwd файл CUPS
mkdir -p /etc/cups
echo "${CUPSADMIN}:$(openssl passwd -apr1 ${CUPSPASSWORD})" > /etc/cups/passwd.md5

# Прописываем пользователя в SystemGroup
cupsctl --no-remote-admin 2>/dev/null || true

# Запускаем avahi
mkdir -p /var/run/avahi-daemon
avahi-daemon --no-drop-root --no-chroot -D || true

# Запускаем cups
cupsd

# Запускаем слежку за принтерами в фоне
/printer-update.sh &

# Держим контейнер живым через лог
tail -f /var/log/cups/error_log
