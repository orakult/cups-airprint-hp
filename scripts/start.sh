#!/bin/sh
set -e

# Копируем конфиги из /config если есть
[ -f /config/cupsd.conf ]    && cp /config/cupsd.conf    /etc/cups/cupsd.conf
[ -f /config/printers.conf ] && cp /config/printers.conf /etc/cups/printers.conf

# Создаём admin пользователя
CUPSADMIN=${CUPSADMIN:-admin}
CUPSPASSWORD=${CUPSPASSWORD:-admin}
echo "${CUPSADMIN}:${CUPSPASSWORD}" | chpasswd

# Запускаем avahi
mkdir -p /var/run/avahi-daemon
avahi-daemon --no-drop-root --no-chroot -D || true

# Запускаем cups
cupsd

# Запускаем слежку за принтерами в фоне
/printer-update.sh &

# Держим контейнер живым через лог
tail -f /var/log/cups/error_log
