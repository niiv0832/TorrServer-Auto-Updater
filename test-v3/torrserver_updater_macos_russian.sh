#!/bin/bash

# TorrServer Авто-Обновление Скрипт для macOS
# Автоматически определяет архитектуру процессора и скачивает соответствующую версию
# Поддерживаемые архитектуры: x86_64 (Intel), arm64 (Apple Silicon)

# Функция справки
show_help() {
    cat << EOF
TorrServer Авто-Обновление для macOS v2.0

ИСПОЛЬЗОВАНИЕ:
    $0 [ОПЦИИ]

ОПЦИИ:
    -h, --help      Показать эту справку
    -f, --force     Принудительное обновление (игнорирует проверку версий)
    -c, --check     Только проверить наличие обновлений
    
ПОДДЕРЖИВАЕМЫЕ АРХИТЕКТУРЫ:
    x86_64 (Intel)        → TorrServer-darwin-amd64
    arm64 (Apple Silicon) → TorrServer-darwin-arm64

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
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ОШИБКА:${NC} $1"
}

warn() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] ПРЕДУПРЕЖДЕНИЕ:${NC} $1"
}

# Функция определения архитектуры для macOS
detect_architecture() {
    local arch=$(uname -m)
    local platform=""
    
    case $arch in
        x86_64)
            platform="darwin-amd64"
            ;;
        arm64)
            platform="darwin-arm64"
            ;;
        *)
            error "Неподдерживаемая архитектура: $arch"
            error "Версия для macOS поддерживает только Intel (x86_64) и Apple Silicon (arm64)"
            exit 1
            ;;
    esac
    
    echo "$platform"
}

# Функция автоматического определения пути установки TorrServer на macOS
detect_torrserver_path() {
    local binary_name="TorrServer-$ARCH_PLATFORM"
    local detected_path=""
    
    log "Определение пути установки TorrServer..."
    
    # Метод 1: Проверка запущенной службы и получение пути из launchd
    if launchctl list | grep -q "com.torrserver.daemon" 2>/dev/null; then
        local plist_path="/Library/LaunchDaemons/com.torrserver.daemon.plist"
        if [ -f "$plist_path" ]; then
            local service_path=$(grep -A1 "<key>Program</key>" "$plist_path" | grep "<string>" | sed 's/.*<string>\(.*\)<\/string>.*/\1/')
            if [ -n "$service_path" ] && [ -f "$service_path" ]; then
                detected_path="$service_path"
                log "Найдена запущенная служба с путём: $detected_path"
            fi
        fi
    fi
    
    # Метод 2: Проверка файла launchd plist, даже если служба не запущена
    if [ -z "$detected_path" ] && [ -f "/Library/LaunchDaemons/com.torrserver.daemon.plist" ]; then
        local service_path=$(grep -A1 "<key>Program</key>" "/Library/LaunchDaemons/com.torrserver.daemon.plist" | grep "<string>" | sed 's/.*<string>\(.*\)<\/string>.*/\1/')
        if [ -n "$service_path" ] && [ -f "$service_path" ]; then
            detected_path="$service_path"
            log "Найден путь в файле launchd plist: $detected_path"
        fi
    fi
    
    # Метод 3: Поиск существующих бинарников TorrServer в обычных местах macOS
    if [ -z "$detected_path" ]; then
        local search_paths=(
            "/usr/local/bin/$binary_name"
            "/usr/local/torrserver/$binary_name"
            "/opt/torrserver/$binary_name"
            "/Applications/TorrServer/$binary_name"
            "/usr/local/bin/TorrServer-darwin-amd64"
            "/usr/local/bin/TorrServer-darwin-arm64"
            "/usr/local/torrserver/TorrServer-darwin-amd64"
            "/usr/local/torrserver/TorrServer-darwin-arm64"
            "/opt/torrserver/TorrServer-darwin-amd64"
            "/opt/torrserver/TorrServer-darwin-arm64"
            "/Users/*/torrserver/$binary_name"
            "/Users/*/Applications/TorrServer/$binary_name"
        )
        
        for path in "${search_paths[@]}"; do
            # Обработка путей с масками
            if [[ "$path" == *"*"* ]]; then
                for expanded_path in $path; do
                    if [ -f "$expanded_path" ] && [ -x "$expanded_path" ]; then
                        detected_path="$expanded_path"
                        log "Найден существующий бинарник: $detected_path"
                        break 2
                    fi
                done
            else
                if [ -f "$path" ] && [ -x "$path" ]; then
                    detected_path="$path"
                    log "Найден существующий бинарник: $detected_path"
                    break
                fi
            fi
        done
    fi
    
    # Метод 4: Поиск с помощью команды find (более тщательный, но медленный)
    if [ -z "$detected_path" ]; then
        log "Выполняется поиск бинарников TorrServer по всей системе..."
        local find_result=$(find /usr/local /opt /Applications /Users -name "TorrServer-*" -type f -perm +111 2>/dev/null | head -1)
        if [ -n "$find_result" ]; then
            detected_path="$find_result"
            log "Найден бинарник через системный поиск: $detected_path"
        fi
    fi
    
    # Метод 5: Использование пути по умолчанию, если ничего не найдено
    if [ -z "$detected_path" ]; then
        detected_path="/usr/local/bin/$binary_name"
        log "Существующая установка не найдена, используется путь по умолчанию: $detected_path"
    fi
    
    echo "$detected_path"
}

# Определение архитектуры
ARCH_PLATFORM=$(detect_architecture)
log "Определена архитектура: $ARCH_PLATFORM"

# Настройки
TORRSERVER_BINARY="TorrServer-$ARCH_PLATFORM"
TORRSERVER_PATH=$(detect_torrserver_path)
TORRSERVER_DIR=$(dirname "$TORRSERVER_PATH")
VERSION_FILE="$TORRSERVER_DIR/.version"
SERVICE_NAME="com.torrserver.daemon"
PLIST_PATH="/Library/LaunchDaemons/$SERVICE_NAME.plist"

log "Путь TorrServer: $TORRSERVER_PATH"
log "Директория TorrServer: $TORRSERVER_DIR"

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

# Функция проверки доступности файла для архитектуры
check_architecture_support() {
    local version=$1
    local binary_name=$2
    local check_url="https://github.com/YouROK/TorrServer/releases/download/$version/$binary_name"
    
    log "Проверка доступности файла для архитектуры $ARCH_PLATFORM..."
    
    # Проверяем доступность файла через HTTP HEAD запрос
    if ! curl -s --head "$check_url" | head -n 1 | grep -q "200 OK"; then
        error "Файл $binary_name не найден для версии $version"
        error "Возможно, данная архитектура не поддерживается в этой версии"
        
        # Показываем доступные файлы
        log "Получение списка доступных файлов..."
        available_files=$(curl -s "https://api.github.com/repos/YouROK/TorrServer/releases/tags/$version" | grep "browser_download_url" | awk -F'"' '{print $4}' | xargs -n1 basename)
        
        if [ -n "$available_files" ]; then
            warn "Доступные файлы для версии $version:"
            echo "$available_files" | while read -r file; do
                echo "  - $file"
            done
        fi
        
        exit 1
    fi
    
    log "Файл для архитектуры найден и доступен"
}

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
if launchctl list | grep -q "$SERVICE_NAME" 2>/dev/null; then
    launchctl stop "$SERVICE_NAME" 2>/dev/null || true
    launchctl unload "$PLIST_PATH" 2>/dev/null || true
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

if ! curl -L -o "$TEMP_FILE" "$download_url"; then
    error "Ошибка при скачивании новой версии"
    
    # Восстановление резервной копии
    if [ -f "${TORRSERVER_PATH}.backup" ]; then
        log "Восстановление резервной копии..."
        mv "${TORRSERVER_PATH}.backup" "$TORRSERVER_PATH"
    fi
    
    # Запуск сервиса
    if [ -f "$PLIST_PATH" ]; then
        launchctl load "$PLIST_PATH" 2>/dev/null || true
        launchctl start "$SERVICE_NAME" 2>/dev/null || true
    fi
    exit 1
fi

# Проверка целостности скачанного файла
if [ ! -s "$TEMP_FILE" ]; then
    error "Скачанный файл пуст или поврежден"
    exit 1
fi

# Создание директории если не существует
mkdir -p "$TORRSERVER_DIR"

# Перемещение нового файла
log "Установка новой версии..."
mv "$TEMP_FILE" "$TORRSERVER_PATH"

# Установка прав на исполнение
chmod +x "$TORRSERVER_PATH"

# Сохранение информации о версии
echo "$latest_version" > "$VERSION_FILE"

# Функция создания launchd plist файла
create_launchd_service() {
    if [ ! -f "$PLIST_PATH" ]; then
        log "Создание launchd service файла..."
        
        cat > "$PLIST_PATH" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$SERVICE_NAME</string>
    <key>Program</key>
    <string>$TORRSERVER_PATH</string>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/var/log/torrserver.log</string>
    <key>StandardErrorPath</key>
    <string>/var/log/torrserver.error.log</string>
    <key>WorkingDirectory</key>
    <string>$TORRSERVER_DIR</string>
</dict>
</plist>
EOF
        
        # Установка правильных разрешений для plist файла
        chmod 644 "$PLIST_PATH"
        chown root:wheel "$PLIST_PATH"
        
        log "Launchd service создан"
    else
        # Обновление существующего plist файла, если путь изменился
        local current_program=$(grep -A1 "<key>Program</key>" "$PLIST_PATH" | grep "<string>" | sed 's/.*<string>\(.*\)<\/string>.*/\1/')
        if [ "$current_program" != "$TORRSERVER_PATH" ]; then
            log "Обновление launchd service файла с новым путём..."
            
            # Остановка и выгрузка старой службы
            launchctl stop "$SERVICE_NAME" 2>/dev/null || true
            launchctl unload "$PLIST_PATH" 2>/dev/null || true
            
            # Обновление plist файла
            sed -i '' "s|<string>$current_program</string>|<string>$TORRSERVER_PATH</string>|" "$PLIST_PATH"
            
            log "Launchd service обновлён"
        fi
    fi
}

# Создание launchd service если не существует
create_launchd_service

# Удаление резервной копии при успешном обновлении
if [ -f "${TORRSERVER_PATH}.backup" ]; then
    rm -f "${TORRSERVER_PATH}.backup"
fi

# Запуск сервиса
log "Запуск сервиса $SERVICE_NAME..."
if ! launchctl load "$PLIST_PATH" 2>/dev/null; then
    warn "Служба может уже быть загружена"
fi

if ! launchctl start "$SERVICE_NAME" 2>/dev/null; then
    warn "Служба может уже работать или не удалось запустить"
fi

# Проверка статуса сервиса
sleep 3
if launchctl list | grep -q "$SERVICE_NAME" 2>/dev/null; then
    log "Служба успешно запущена"
else
    warn "Служба может работать некорректно. Проверьте статус: launchctl list | grep torrserver"
    warn "Проверьте логи: tail -f /var/log/torrserver.log"
fi

log "Обновление TorrServer завершено успешно!"
log "Архитектура: $ARCH_PLATFORM"
log "Версия: $current_version → $latest_version"
log "Путь к исполняемому файлу: $TORRSERVER_PATH"
log "Управление службой: Используйте команды 'launchctl' для управления службой"