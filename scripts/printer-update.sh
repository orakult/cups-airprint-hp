#!/bin/sh
SERVICES_DIR=/services
mkdir -p "$SERVICES_DIR"

generate_services() {
    rm -f "$SERVICES_DIR"/AirPrint-*.service

    lpstat -p 2>/dev/null | grep '^printer ' | awk '{print $2}' | while read printer; do
        cat > "$SERVICES_DIR/AirPrint-${printer}.service" << SVCEOF
<?xml version="1.0" ?>
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">
<service-group>
  <name replace-wildcards="yes">AirPrint ${printer} @ %h</name>
  <service>
    <type>_ipp._tcp</type>
    <subtype>_universal._sub._ipp._tcp</subtype>
    <port>631</port>
    <txt-record>txtvers=1</txt-record>
    <txt-record>qtotal=1</txt-record>
    <txt-record>rp=printers/${printer}</txt-record>
    <txt-record>pdl=application/pdf,application/postscript,image/urf,image/jpeg,image/png</txt-record>
    <txt-record>URF=DM3</txt-record>
    <txt-record>Transparent=T</txt-record>
    <txt-record>printer-state=3</txt-record>
  </service>
</service-group>
SVCEOF
    done
}

sleep 10
generate_services

inotifywait -m -e close_write /etc/cups/printers.conf 2>/dev/null | while read; do
    sleep 2
    generate_services
done
