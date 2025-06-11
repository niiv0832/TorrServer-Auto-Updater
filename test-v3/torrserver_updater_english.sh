#!/bin/bash

# TorrServer Auto-Updater Script
# Automatically detects processor architecture and downloads the appropriate version
# Supported architectures: x86_64, aarch64, armv7l, i386

# Help function
show_help() {
    cat << EOF
TorrServer Auto-Updater v2.0

USAGE:
    $0 [OPTIONS]

OPTIONS:
    -h, --help      Show this help information
    -f, --force     Force update (ignore version check)
    -c, --check     Check for updates only (no download)
    
SUPPORTED ARCHITECTURES:
    x86_64/amd64    → TorrServer-linux-amd64
    aarch64/arm64   → TorrServer-linux-arm64  
    armv7l/armhf    → TorrServer-linux-arm
    i386/i686       → TorrServer-linux-386

EXAMPLES:
    $0              # Normal update
    $0 --force      # Force update
    $0 --check      # Check for updates only

EOF
}

# Process command line arguments
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
            error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1"
}

warn() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1"
}

# Architecture detection function
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
            error "Unsupported architecture: $arch"
            exit 1
            ;;
    esac
    
    echo "$platform"
}

# Function to detect TorrServer installation path
detect_torrserver_path() {
    local binary_name="TorrServer-$ARCH_PLATFORM"
    local detected_path=""
    
    log "Detecting TorrServer installation path..."
    
    # Method 1: Check if service is running and get path from systemd
    if systemctl is-active --quiet "$SERVICE_NAME" 2>/dev/null; then
        local service_path=$(systemctl show -p ExecStart --value "$SERVICE_NAME" 2>/dev/null | awk '{print $1}')
        if [ -n "$service_path" ] && [ -f "$service_path" ]; then
            detected_path="$service_path"
            log "Found running service with path: $detected_path"
        fi
    fi
    
    # Method 2: Check systemd service file even if service is not running
    if [ -z "$detected_path" ] && [ -f "/etc/systemd/system/$SERVICE_NAME.service" ]; then
        local service_path=$(grep "ExecStart=" "/etc/systemd/system/$SERVICE_NAME.service" | sed 's/ExecStart=//' | awk '{print $1}')
        if [ -n "$service_path" ] && [ -f "$service_path" ]; then
            detected_path="$service_path"
            log "Found path in systemd service file: $detected_path"
        fi
    fi
    
    # Method 3: Search for existing TorrServer binaries in common locations
    if [ -z "$detected_path" ]; then
        local search_paths=(
            "/opt/torrserver/$binary_name"
            "/opt/torrserver/TorrServer-linux-amd64"
            "/opt/torrserver/TorrServer-linux-arm64"
            "/opt/torrserver/TorrServer-linux-arm"
            "/opt/torrserver/TorrServer-linux-386"
            "/usr/local/bin/$binary_name"
            "/usr/bin/$binary_name"
            "/home/*/torrserver/$binary_name"
            "/root/torrserver/$binary_name"
        )
        
        for path in "${search_paths[@]}"; do
            # Handle wildcard paths
            if [[ "$path" == *"*"* ]]; then
                for expanded_path in $path; do
                    if [ -f "$expanded_path" ] && [ -x "$expanded_path" ]; then
                        detected_path="$expanded_path"
                        log "Found existing binary: $detected_path"
                        break 2
                    fi
                done
            else
                if [ -f "$path" ] && [ -x "$path" ]; then
                    detected_path="$path"
                    log "Found existing binary: $detected_path"
                    break
                fi
            fi
        done
    fi
    
    # Method 4: Search using find command (more thorough but slower)
    if [ -z "$detected_path" ]; then
        log "Performing system-wide search for TorrServer binaries..."
        local find_result=$(find /opt /usr/local /usr /home /root -name "TorrServer-*" -type f -executable 2>/dev/null | head -1)
        if [ -n "$find_result" ]; then
            detected_path="$find_result"
            log "Found binary via system search: $detected_path"
        fi
    fi
    
    # Method 5: Use default path if nothing found
    if [ -z "$detected_path" ]; then
        detected_path="/opt/torrserver/$binary_name"
        log "No existing installation found, using default path: $detected_path"
    fi
    
    echo "$detected_path"
}

# Detect architecture
ARCH_PLATFORM=$(detect_architecture)
log "Detected architecture: $ARCH_PLATFORM"

# Settings
TORRSERVER_BINARY="TorrServer-$ARCH_PLATFORM"
TORRSERVER_PATH=$(detect_torrserver_path)
TORRSERVER_DIR=$(dirname "$TORRSERVER_PATH")
VERSION_FILE="$TORRSERVER_DIR/.version"
SERVICE_NAME="torrserver"

log "TorrServer path: $TORRSERVER_PATH"
log "TorrServer directory: $TORRSERVER_DIR"

# Check sudo privileges
if [[ $EUID -ne 0 ]]; then
   error "This script must be run as root (sudo)"
   exit 1
fi

log "Checking for TorrServer updates..."

# Get latest version from GitHub API
log "Getting latest version information..."
latest_version=$(curl -s https://api.github.com/repos/YouROK/TorrServer/releases/latest | grep "tag_name" | awk -F'"' '{print $4}')

if [ -z "$latest_version" ]; then
    error "Failed to get latest version information"
    exit 1
fi

log "Latest version on GitHub: $latest_version"

# Get current installed version
current_version=""
if [ -f "$VERSION_FILE" ]; then
    current_version=$(cat "$VERSION_FILE")
    log "Current installed version: $current_version"
else
    warn "Version file not found. This might be the first installation."
fi

# Version comparison
if [ "$current_version" = "$latest_version" ] && [ "$FORCE_UPDATE" = false ]; then
    log "You already have the latest version ($current_version)"
    log "No update required"
    
    if [ "$CHECK_ONLY" = true ]; then
        log "Check-only mode - exiting"
    else
        log "Use --force flag for forced update"
    fi
    exit 0
fi

if [ "$CHECK_ONLY" = true ]; then
    log "New version available: $latest_version (current: $current_version)"
    log "Run the script without --check flag to update"
    exit 0
fi

if [ "$FORCE_UPDATE" = true ]; then
    log "Force update: $current_version → $latest_version"
else
    log "New version found: $latest_version"
fi

# Function to check architecture file availability
check_architecture_support() {
    local version=$1
    local binary_name=$2
    local check_url="https://github.com/YouROK/TorrServer/releases/download/$version/$binary_name"
    
    log "Checking file availability for architecture $ARCH_PLATFORM..."
    
    # Check file availability via HTTP HEAD request
    if ! curl -s --head "$check_url" | head -n 1 | grep -q "200 OK"; then
        error "File $binary_name not found for version $version"
        error "This architecture might not be supported in this version"
        
        # Show available files
        log "Getting list of available files..."
        available_files=$(curl -s "https://api.github.com/repos/YouROK/TorrServer/releases/tags/$version" | grep "browser_download_url" | awk -F'"' '{print $4}' | xargs -n1 basename)
        
        if [ -n "$available_files" ]; then
            warn "Available files for version $version:"
            echo "$available_files" | while read -r file; do
                echo "  - $file"
            done
        fi
        
        exit 1
    fi
    
    log "File for architecture found and available"
}

# Check architecture support
check_architecture_support "$latest_version" "$TORRSERVER_BINARY"

log "Starting update..."

# Create backup of current file (if exists)
if [ -f "$TORRSERVER_PATH" ]; then
    log "Creating backup of current version..."
    cp "$TORRSERVER_PATH" "${TORRSERVER_PATH}.backup"
fi

# Stop service before update
log "Stopping $SERVICE_NAME service..."
if systemctl is-active --quiet "$SERVICE_NAME"; then
    systemctl stop "$SERVICE_NAME"
    sleep 2
fi

# Clean temporary files
TEMP_FILE="/tmp/$TORRSERVER_BINARY"
log "Cleaning temporary files..."
rm -rf "$TEMP_FILE"

# Go to temporary directory
cd /tmp || exit 1

# Download new version
log "Downloading TorrServer version $latest_version for architecture $ARCH_PLATFORM..."
download_url="https://github.com/YouROK/TorrServer/releases/download/$latest_version/$TORRSERVER_BINARY"

if ! wget -O "$TEMP_FILE" "$download_url"; then
    error "Error downloading new version"
    
    # Restore backup
    if [ -f "${TORRSERVER_PATH}.backup" ]; then
        log "Restoring backup..."
        mv "${TORRSERVER_PATH}.backup" "$TORRSERVER_PATH"
    fi
    
    # Start service
    systemctl start "$SERVICE_NAME"
    exit 1
fi

# Check integrity of downloaded file
if [ ! -s "$TEMP_FILE" ]; then
    error "Downloaded file is empty or corrupted"
    exit 1
fi

# Create directory if not exists
mkdir -p "$TORRSERVER_DIR"

# Move new file
log "Installing new version..."
mv "$TEMP_FILE" "$TORRSERVER_PATH"

# Set execution permissions
chmod +x "$TORRSERVER_PATH"

# Save version information
echo "$latest_version" > "$VERSION_FILE"

# Function to create systemd service file
create_systemd_service() {
    local service_file="/etc/systemd/system/$SERVICE_NAME.service"
    
    if [ ! -f "$service_file" ]; then
        log "Creating systemd service file..."
        
        cat > "$service_file" << EOF
[Unit]
Description=TorrServer
After=network.target

[Service]
Type=simple
User=root
ExecStart=$TORRSERVER_PATH
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
        
        systemctl daemon-reload
        systemctl enable "$SERVICE_NAME"
        log "Systemd service created and enabled"
    else
        # Update existing service file if path changed
        local current_exec=$(grep "ExecStart=" "$service_file" | sed 's/ExecStart=//' | awk '{print $1}')
        if [ "$current_exec" != "$TORRSERVER_PATH" ]; then
            log "Updating systemd service file with new path..."
            sed -i "s|ExecStart=.*|ExecStart=$TORRSERVER_PATH|" "$service_file"
            systemctl daemon-reload
            log "Systemd service updated"
        fi
    fi
}

# Create systemd service if it doesn't exist
create_systemd_service

# Remove backup on successful update
if [ -f "${TORRSERVER_PATH}.backup" ]; then
    rm -f "${TORRSERVER_PATH}.backup"
fi

# Start service
log "Starting $SERVICE_NAME service..."
if ! systemctl start "$SERVICE_NAME"; then
    error "Error starting service"
    exit 1
fi

# Check service status
sleep 3
if systemctl is-active --quiet "$SERVICE_NAME"; then
    log "Service started successfully"
else
    warn "Service may not be working correctly. Check status: systemctl status $SERVICE_NAME"
fi

log "TorrServer update completed successfully!"
log "Architecture: $ARCH_PLATFORM"
log "Version: $current_version → $latest_version"
log "Executable path: $TORRSERVER_PATH"