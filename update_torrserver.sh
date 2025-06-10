#!/bin/bash

# TorrServer Auto-Updater Script
# Автоматически определяет архитектуру процессора и скачивает соответствующую версию
# Поддерживаемые архитектуры: x86_64, aarch64, armv7l, i386

# Функция справки
show_help() {
    cat << EOF
TorrServer Auto-Updater v2.0

ИСПОЛЬЗОВАНИЕ:
    $0 [ОПЦИИ]

ОПЦИИ:
    -h, --help      Показать эту справку
    -f, --force     Принудительное обновление (игнорирует проверку версий)
    -c, --check     Только проверить наличие обновлений
    
ПОДДЕРЖИВАЕМЫЕ АРХИТЕКТУРЫ:
    x86_64/amd64    → TorrServer-linux-amd64
    aarch64/arm64   → TorrServer-linux-arm64  
    armv7l/armhf    → TorrServer-linux-arm
    i386/i686       → TorrServer-linux-386

ПРИМЕРЫ:
    $0              # Обычное обновление
    $0 --force      # Принудительное обновление
    $0 --check      # Только проверка обновлений

EOF
}

# Обработка аргументов командной строки
FORCE_UPDATE=false
CHECK_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -f|--force)
            FORCE_UPDATE=true
            shift
            ;;
        -c|--check)
            CHECK_ONLY=true
            shift
            ;;
        *)
            error "Неизвестная опция: $1"
            show_help
            exit 1
            ;;
    esac
done

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Функция для логирования
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1"
}

warn() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1"
}

# Функция определения архитектуры
detect_architecture() {
    local arch=$(uname -m)
    local platform=""
    
    case $arch in
        x86_64|amd64)
            platform="linux-amd64"
            ;;
        aarch64|arm64)
            platform="linux-arm64"
            ;;
        armv7l|armhf)
            platform="linux-arm"
            ;;
        i386|i686)
            platform="linux-386"
            ;;
        *)
            error "Неподдерживаемая архитектура: $arch"
            exit 1
            ;;
    esac
    
    echo "$platform"
}

# Определение архитектуры
ARCH_PLATFORM=$(detect_architecture)
log "Определена архитектура: $ARCH_PLATFORM"

# Настройки
TORRSERVER_BINARY="TorrServer-$ARCH_PLATFORM"
TORRSERVER_PATH="/opt/torrserver/$TORRSERVER_BINARY"
VERSION_FILE="/opt/torrserver/.version"
SERVICE_NAME="torrserver"

# Проверка прав sudo
if [[ $EUID -ne 0 ]]; then
   error "Этот скрипт должен быть запущен с правами root (sudo)"
   exit 1
fi

log "Проверка обновлений TorrServer..."

# Получение последней версии с GitHub API
log "Получение информации о последней версии..."
latest_version=$(curl -s https://api.github.com/repos/YouROK/TorrServer/releases/latest | grep "tag_name" | awk -F'"' '{print $4}')

if [ -z "$latest_version" ]; then
    error "Не удалось получить информацию о последней версии"
    exit 1
fi

log "Последняя версия на GitHub: $latest_version"

# Получение текущей установленной версии
current_version=""
if [ -f "$VERSION_FILE" ]; then
    current_version=$(cat "$VERSION_FILE")
    log "Текущая установленная версия: $current_version"
else
    warn "Файл с версией не найден. Возможно, это первая установка."
fi

# Сравнение версий
if [ "$current_version" = "$latest_version" ] && [ "$FORCE_UPDATE" = false ]; then
    log "У вас уже установлена последняя версия ($current_version)"
    log "Обновление не требуется"
    
    if [ "$CHECK_ONLY" = true ]; then
        log "Режим только проверки - завершение работы"
    else
        log "Используйте флаг --force для принудительного обновления"
    fi
    exit 0
fi

if [ "$CHECK_ONLY" = true ]; then
    log "Доступна новая версия: $latest_version (текущая: $current_version)"
    log "Для обновления запустите скрипт без флага --check"
    exit 0
fi

if [ "$FORCE_UPDATE" = true ]; then
    log "Принудительное обновление: $current_version → $latest_version"
else
    log "Найдена новая версия: $latest_version"
fi

# Проверяем поддержку архитектуры
check_architecture_support "$latest_version" "$TORRSERVER_BINARY"

log "Начинаю обновление..."

# Создание резервной копии (если файл существует)
if [ -f "$TORRSERVER_PATH" ]; then
    log "Создание резервной копии текущей версии..."
    cp "$TORRSERVER_PATH" "${TORRSERVER_PATH}.backup"
fi

# Остановка сервиса перед обновлением
log "Остановка сервиса $SERVICE_NAME..."
if systemctl is-active --quiet "$SERVICE_NAME"; then
    systemctl stop "$SERVICE_NAME"
    sleep 2
fi

# Очистка временных файлов
TEMP_FILE="/tmp/$TORRSERVER_BINARY"
log "Очистка временных файлов..."
rm -rf "$TEMP_FILE"

# Переход в временную директорию
cd /tmp || exit 1

# Скачивание новой версии
log "Скачивание TorrServer версии $latest_version для архитектуры $ARCH_PLATFORM..."
download_url="https://github.com/YouROK/TorrServer/releases/download/$latest_version/$TORRSERVER_BINARY"

if ! wget -O "$TEMP_FILE" "$download_url"; then
    error "Ошибка при скачивании новой версии"
    
    # Восстановление резервной копии
    if [ -f "${TORRSERVER_PATH}.backup" ]; then
        log "Восстановление резервной копии..."
        mv "${TORRSERVER_PATH}.backup" "$TORRSERVER_PATH"
    fi
    
    # Запуск сервиса
    systemctl start "$SERVICE_NAME"
    exit 1
fi

# Проверка целостности скачанного файла
if [ ! -s "$TEMP_FILE" ]; then
    error "Скачанный файл пуст или поврежден"
    exit 1
fi

# Создание директории если не существует
mkdir -p /opt/torrserver

# Перемещение нового файла
log "Установка новой версии..."
mv "$TEMP_FILE" "$TORRSERVER_PATH"

# Установка прав на исполнение
chmod +x "$TORRSERVER_PATH"

# Сохранение информации о версии
echo "$latest_version" > "$VERSION_FILE"

# Создание systemd service если не существует
create_systemd_service

# Удаление резервной копии при успешном обновлении
if [ -f "${TORRSERVER_PATH}.backup" ]; then
    rm -f "${TORRSERVER_PATH}.backup"
fi

# Запуск сервиса
log "Запуск сервиса $SERVICE_NAME..."
if ! systemctl start "$SERVICE_NAME"; then
    error "Ошибка при запуске сервиса"
    exit 1
fi

# Проверка статуса сервиса
sleep 3
if systemctl is-active --quiet "$SERVICE_NAME"; then
    log "Сервис успешно запущен"
else
    warn "Сервис может работать некорректно. Проверьте статус: systemctl status $SERVICE_NAME"
fi

log "Обновление TorrServer завершено успешно!"
log "Архитектура: $ARCH_PLATFORM"
log "Версия: $current_version → $latest_version"
log "Путь к исполняемому файлу: $TORRSERVER_PATH"
