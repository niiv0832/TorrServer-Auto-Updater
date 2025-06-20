# TorrServer Авто-Обновление

Интеллектуальный кроссплатформенный скрипт обновления для TorrServer с автоматическим определением архитектуры и комплексными функциями безопасности.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Language-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/Platform-Linux-blue.svg)](https://www.linux.org/)

## 🚀 Возможности

### 🔧 **Поддержка Множественных Архитектур**
Автоматически определяет архитектуру вашей системы и скачивает соответствующий бинарный файл TorrServer:

| Архитектура | Определение | Бинарный файл |
|-------------|-------------|---------------|
| x86_64/AMD64 | `uname -m` → x86_64 | `TorrServer-linux-amd64` |
| ARM64/AArch64 | `uname -m` → aarch64 | `TorrServer-linux-arm64` |
| ARMv7/ARMhf | `uname -m` → armv7l | `TorrServer-linux-arm` |
| i386/i686 | `uname -m` → i386 | `TorrServer-linux-386` |

### 🛡️ **Безопасность и Надёжность**
- **Умная Проверка Версий**: Обновляет только при наличии новой версии
- **Автоматическое Резервное Копирование**: Создаёт резервную копию перед обновлением с откатом при сбое
- **Валидация Бинарных Файлов**: Проверяет целостность загрузки и совместимость архитектуры
- **Управление Службами**: Правильная обработка systemd служб с проверками работоспособности
- **Проверка Разрешений**: Убеждается, что скрипт запущен с соответствующими привилегиями

### 📋 **Интерфейс Командной Строки**
```bash
TorrServer Авто-Обновление v2.0

ИСПОЛЬЗОВАНИЕ:
    ./update_torrserver.sh [ОПЦИИ]

ОПЦИИ:
    -h, --help      Показать справочную информацию
    -f, --force     Принудительное обновление (игнорировать проверку версий)
    -c, --check     Только проверить обновления (без скачивания)
```

### 📝 **Улучшенное Логирование**
- **Цветной вывод** с временными метками и уровнями важности
- **Индикаторы прогресса** для всех операций
- **Подробные сообщения об ошибках** с подсказками по устранению неполадок
- **Сводка операций** с информацией о версиях до/после

## 📦 Установка

### Быстрая Установка
```bash
# Скачать скрипт
wget https://raw.githubusercontent.com/YouROK/TorrServer/main/update_torrserver.sh

# Сделать исполняемым
chmod +x update_torrserver.sh

# Запустить обновление
sudo ./update_torrserver.sh
```

### Ручная Установка
1. Скачайте скрипт в удобное место
2. Установите права на выполнение: `chmod +x update_torrserver.sh`
3. Запустите с правами root: `sudo ./update_torrserver.sh`

## 🚀 Использование

### Базовое Использование
```bash
# Стандартное обновление (рекомендуется)
sudo ./update_torrserver.sh
```

### Продвинутое Использование
```bash
# Проверить обновления без установки
sudo ./update_torrserver.sh --check

# Принудительное обновление независимо от текущей версии
sudo ./update_torrserver.sh --force

# Показать справку и информацию об использовании
./update_torrserver.sh --help
```

### Пример Вывода
```bash
$ sudo ./update_torrserver.sh

[2025-06-11 14:30:15] Проверка обновлений TorrServer...
[2025-06-11 14:30:16] Определена архитектура: linux-amd64
[2025-06-11 14:30:17] Получение информации о последней версии...
[2025-06-11 14:30:18] Последняя версия на GitHub: MatriX.v1.2.3
[2025-06-11 14:30:18] Текущая установленная версия: MatriX.v1.2.2
[2025-06-11 14:30:18] Найдена новая версия: MatriX.v1.2.3
[2025-06-11 14:30:19] Проверка поддержки архитектуры...
[2025-06-11 14:30:20] Файл для архитектуры найден и доступен
[2025-06-11 14:30:20] Начинаю обновление...
[2025-06-11 14:30:21] Создание резервной копии текущей версии...
[2025-06-11 14:30:22] Остановка службы torrserver...
[2025-06-11 14:30:24] Скачивание TorrServer версии MatriX.v1.2.3 для linux-amd64...
[2025-06-11 14:30:28] Установка новой версии...
[2025-06-11 14:30:29] Запуск службы torrserver...
[2025-06-11 14:30:32] Служба успешно запущена
[2025-06-11 14:30:32] Обновление завершено успешно!
[2025-06-11 14:30:32] Архитектура: linux-amd64
[2025-06-11 14:30:32] Версия: MatriX.v1.2.2 → MatriX.v1.2.3
[2025-06-11 14:30:32] Путь к исполняемому файлу: /opt/torrserver/TorrServer-linux-amd64
```

## 🔧 Конфигурация

### Пути по Умолчанию
- **Расположение бинарника**: `/opt/torrserver/TorrServer-{архитектура}`
- **Файл версии**: `/opt/torrserver/.version`
- **Имя службы**: `torrserver`
- **Systemd служба**: `/etc/systemd/system/torrserver.service`

### Настройка
Вы можете изменить эти переменные в верхней части скрипта:
```bash
# Пользовательские пути (редактируйте в скрипте)
TORRSERVER_PATH="/opt/torrserver/$TORRSERVER_BINARY"
VERSION_FILE="/opt/torrserver/.version"
SERVICE_NAME="torrserver"
```

## 🛠️ Устранение Неполадок

### Распространённые Проблемы

#### Отказано в Доступе
```bash
ОШИБКА: Этот скрипт должен быть запущен с правами root (sudo)
```
**Решение**: Запустите с `sudo ./update_torrserver.sh`

#### Архитектура не Поддерживается
```bash
ОШИБКА: Неподдерживаемая архитектура: mips64
```
**Решение**: Проверьте, предоставляет ли TorrServer бинарники для вашей архитектуры

#### Ошибка Скачивания
```bash
ОШИБКА: Ошибка при скачивании новой версии
```
**Решения**:
- Проверьте интернет-соединение
- Убедитесь, что GitHub доступен
- Попробуйте позже (временные проблемы с сервером)

#### Служба не Запускается
```bash
ПРЕДУПРЕЖДЕНИЕ: Служба может работать некорректно
```
**Решения**:
- Проверьте статус службы: `systemctl status torrserver`
- Просмотрите логи: `journalctl -u torrserver -f`
- Проверьте права на бинарник: `ls -la /opt/torrserver/`

### Режим Отладки
Для подробного устранения неполадок можно включить отладочный вывод:
```bash
# Добавьте флаг отладки в скрипт
set -x
sudo ./update_torrserver.sh
```

## 🔄 Миграция со Старого Скрипта

Новый скрипт полностью обратно совместим. Для существующих установок:

1. **Ручная миграция не нужна** - скрипт определяет вашу текущую настройку
2. **Ваши данные сохраняются** - обновляется только бинарный файл
3. **Конфигурация службы остаётся** - существующая systemd служба сохраняется
4. **Начинается отслеживание версий** - скрипт начнёт отслеживать версии в дальнейшем

### Первый Запуск После Миграции
```bash
$ sudo ./update_torrserver.sh

[2025-06-11 14:30:15] Проверка обновлений TorrServer...
[2025-06-11 14:30:16] Определена архитектура: linux-arm64
[2025-06-11 14:30:17] Получение информации о последней версии...
[2025-06-11 14:30:18] Последняя версия на GitHub: MatriX.v1.2.3
[2025-06-11 14:30:18] ПРЕДУПРЕЖДЕНИЕ: Файл с версией не найден. Возможно, это первая установка.
[2025-06-11 14:30:18] Найдена новая версия: MatriX.v1.2.3
# ... продолжается обычным процессом обновления
```

## 🧪 Тестирование

Скрипт был протестирован на:

### Операционные Системы
- ✅ Ubuntu 20.04, 22.04, 24.04
- ✅ Debian 10, 11, 12
- ✅ CentOS 7, 8
- ✅ Rocky Linux 8, 9
- ✅ Raspberry Pi OS (32-битная и 64-битная)

### Аппаратные Платформы
- ✅ Intel/AMD x86_64 серверы и настольные компьютеры
- ✅ ARM64 серверы (AWS Graviton, Oracle Ampere)
- ✅ Raspberry Pi 4 (ARM64)
- ✅ Raspberry Pi 3 (ARMv7)
- ✅ Устаревшие x86 системы

## 🤝 Участие в Разработке

Мы приветствуем вклад в развитие! Пожалуйста, не стесняйтесь отправлять pull request'ы или открывать issue.

### Настройка для Разработки
```bash
# Клонировать репозиторий
git clone https://github.com/YouROK/TorrServer.git
cd TorrServer

# Сделать скрипт исполняемым
chmod +x update_torrserver.sh

# Тестировать на вашей платформе
sudo ./update_torrserver.sh --check
```

### Рекомендации по Участию
- Поддерживайте обратную совместимость
- Тестируйте на множественных архитектурах, если возможно
- Следуйте существующему стилю кода и комментариев
- Обновляйте документацию для новых функций

## 📋 Журнал Изменений

### v2.0.0 (Текущая)
- ✅ **Добавлено**: Мульти-архитектурное автоопределение
- ✅ **Добавлено**: Интерфейс командной строки (--help, --force, --check)
- ✅ **Добавлено**: Умная проверка и сравнение версий
- ✅ **Добавлено**: Система резервного копирования и отката
- ✅ **Добавлено**: Валидация архитектуры и проверка доступности
- ✅ **Добавлено**: Улучшенное логирование с цветами и временными метками
- ✅ **Добавлено**: Автоматическое создание systemd службы
- ✅ **Добавлено**: Комплексная обработка ошибок
- ✅ **Улучшено**: Пользовательский опыт и обратная связь
- ✅ **Исправлено**: Синтаксические ошибки в оригинальном скрипте

### v1.0.0 (Оригинальная)
- ✅ Базовое скачивание и установка TorrServer
- ✅ Поддержка только архитектуры ARM64
- ✅ Простой перезапуск systemd службы

## 📄 Лицензия

Этот проект лицензирован под лицензией GPL-3.0 - см. файл [LICENSE](LICENSE) для подробностей.

## 🙏 Благодарности

- **Команда TorrServer** за создание и поддержку TorrServer
- **Участники сообщества** за тестирование и обратную связь
- **GitHub Actions** за автоматизацию релизов

---

**Сделано с ❤️ для сообщества TorrServer**
