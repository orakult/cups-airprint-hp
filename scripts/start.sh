#!/bin/sh
set -e

# Копируем конфиги из /config если есть
[ -f /config/cupsd.conf ]    && cp /config/cupsd.conf    /etc/cups/cupsd.conf
[ -f /config/printers.conf ] && cp /config/printers.conf /etc/cups/printers.conf

# Создаём admin пользователя через CUPS
CUPSADMIN=${CUPSADMIN:-admin}
CUPSPASSWORD=${CUPSPASSWORD:-admin}
useradd -M -s /usr/sbin/nologin "${CUPSADMIN}" 2>/dev/null || true
echo "${CUPSPASSWORD}" | passwd --stdin "${CUPSADMIN}" 2>/dev/null || \
    printf '%s\n%s\n' "${CUPSPASSWORD}" "${CUPSPASSWORD}" | passwd "${CUPSADMIN}" 2>/dev/null || true
lppasswd -a "${CUPSADMIN}" << PASSEOF
${CUPSPASSWORD}
${CUPSPASSWORD}
PASSEOF

# Запускаем avahi
mkdir -p /var/run/avahi-daemon
avahi-daemon --no-drop-root --no-chroot -D || true

# Запускаем cups
cupsd

# Запускаем слежку за принтерами в фоне
/printer-update.sh &

# Держим контейнер живым через лог
tail -f /var/log/cups/error_log
