# cups-airprint-hp

Docker-образ с CUPS и драйверами foo2zjs для принтеров HP LaserJet серии P1100/P1102.
Позволяет печатать с iPhone/iPad через AirPrint на принтеры которые не поддерживают AirPrint нативно.

## Для кого

- У вас HP LaserJet P1102 (или похожий foo2zjs-принтер) подключён к роутеру по USB
- Вы хотите печатать с iPhone/iPad без лишних телодвижений
- У вас есть любой Linux-сервер или роутер с Docker (Raspberry Pi, NanoPi, x86 и т.д.)

## Как это работает
```
iPhone → AirPrint (mDNS/Bonjour) → CUPS → принтер по сети (socket://host:9100)
```

CUPS принимает задание печати, конвертирует через foo2zjs и отправляет на принтер
по сети через RAW-порт 9100. Avahi анонсирует принтер в локальной сети через mDNS
так что iPhone видит его автоматически без какой-либо настройки.

## Требования

- Docker и Docker Compose
- Принтер доступен по сети через порт 9100 (RAW/AppSocket)
- На хосте запущен `avahi-daemon` (есть по умолчанию в большинстве дистрибутивов)

## Быстрый старт

Создай `docker-compose.yml`:
```yaml
version: "3.8"

services:
  cups:
    image: ghcr.io/orakult/cups-airprint-hp:latest
    container_name: cups
    restart: unless-stopped
    network_mode: host
    volumes:
      - ./config:/config
      - /etc/avahi/services:/services
    environment:
      - CUPSADMIN=admin
      - CUPSPASSWORD=ChangeMe123
```

Запусти:
```bash
mkdir -p config
docker compose up -d
```

Открой веб-интерфейс CUPS: `http://<IP-сервера>:631`

## Настройка принтера

1. Открой `http://<IP-сервера>:631`
2. Войди с логином/паролем из `CUPSADMIN` / `CUPSPASSWORD`
3. **Администрирование → Добавить принтер**
4. Выбери **AppSocket/HP JetDirect**
5. URI: `socket://192.168.1.1:9100` (замени на IP своего роутера/принтера)
6. Выбери драйвер: **HP LaserJet Professional P1102** или **P1102w**
7. Поставь галку **Сделать принтер общим**
8. Нажми **Добавить принтер**

Через 30-60 секунд принтер появится на iPhone в меню печати автоматически.

## Переменные окружения

| Переменная | По умолчанию | Описание |
|---|---|---|
| `CUPSADMIN` | `admin` | Имя администратора CUPS |
| `CUPSPASSWORD` | `admin` | Пароль администратора |

## Тома

| Путь в контейнере | Описание |
|---|---|
| `/config` | Конфиги CUPS (printers.conf сохраняется между перезапусками) |
| `/services` | Avahi .service файлы для AirPrint анонсов |

**Важно:** `/services` должен указывать на `/etc/avahi/services` хоста
чтобы хостовой avahi-daemon подхватил принтер и анонсировал его в сеть.

## Поддерживаемые архитектуры

| Архитектура | Тег |
|---|---|
| x86-64 | `linux/amd64` |
| ARM 64-bit | `linux/arm64` |
| ARM 32-bit | `linux/arm/v7` |

Образ собирается автоматически через GitHub Actions при каждом обновлении.

## Протестировано

- NanoPi R3S (aarch64) + FriendlyWRT
- HP LaserJet P1102 подключён к роутеру Keenetic

## Лицензия

MIT
