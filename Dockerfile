FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        cups \
        cups-client \
        cups-filters \
        cups-bsd \
        avahi-daemon \
        avahi-utils \
        libnss-mdns \
        printer-driver-foo2zjs \
        printer-driver-foo2zjs-common \
        inotify-tools \
        procps \
        passwd \
    && rm -rf /var/lib/apt/lists/*

COPY config/cupsd.conf /etc/cups/cupsd.conf

COPY scripts/start.sh /start.sh
COPY scripts/printer-update.sh /printer-update.sh
RUN chmod +x /start.sh /printer-update.sh

VOLUME ["/config", "/services"]
EXPOSE 631

CMD ["/start.sh"]
