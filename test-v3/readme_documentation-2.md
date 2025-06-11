# TorrServer Auto-Updater

An intelligent, cross-platform update script for TorrServer with automatic architecture detection and comprehensive safety features. Supports Linux and macOS.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Language-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/Platform-Linux-blue.svg)](https://www.linux.org/)

## 🚀 Features

### 🔧 **Multi-Architecture Support**
Automatically detects your system architecture and downloads the appropriate TorrServer binary:

#### Linux Support
| Architecture | Detection | Binary |
|--------------|-----------|--------|
| x86_64/AMD64 | `uname -m` → x86_64 | `TorrServer-linux-amd64` |
| ARM64/AArch64 | `uname -m` → aarch64 | `TorrServer-linux-arm64` |
| ARMv7/ARMhf | `uname -m` → armv7l | `TorrServer-linux-arm` |
| i386/i686 | `uname -m` → i386 | `TorrServer-linux-386` |

#### macOS Support
| Architecture | Detection | Binary |
|--------------|-----------|--------|
| Intel Mac | `uname -m` → x86_64 | `TorrServer-darwin-amd64` |
| Apple Silicon | `uname -m` → arm64 | `TorrServer-darwin-arm64` |

### 🛡️ **Safety & Reliability**
- **Smart Version Checking**: Only updates when a newer version is available
- **Automatic Path Detection**: Intelligently finds existing TorrServer installations
- **Automatic Backup**: Creates backup before update with rollback on failure
- **Binary Validation**: Verifies download integrity and architecture compatibility
- **Service Management**: Proper systemd service handling with health checks
- **Permission Verification**: Ensures script runs with appropriate privileges

### 📋 **Command Line Interface**
```bash
TorrServer Auto-Updater v2.0

USAGE:
    ./update_torrserver.sh [OPTIONS]

OPTIONS:
    -h, --help      Show help information
    -f, --force     Force update (ignore version check)
    -c, --check     Check for updates only (no download)
```

### 📝 **Enhanced Logging**
- **Colored output** with timestamp and severity levels
- **Progress indicators** for all operations
- **Detailed error messages** with troubleshooting hints
- **Operation summary** with before/after version info

## 📦 Installation

### Quick Install
```bash
# Download the script
wget https://raw.githubusercontent.com/YouROK/TorrServer/main/update_torrserver.sh

# Make executable
chmod +x update_torrserver.sh

# Run update
sudo ./update_torrserver.sh
```

### Manual Installation
1. Download the script to your preferred location
2. Set executable permissions: `chmod +x update_torrserver.sh`
3. Run with root privileges: `sudo ./update_torrserver.sh`

## 🚀 Usage

### Basic Usage
```bash
# Standard update (recommended)
sudo ./update_torrserver.sh
```

### Advanced Usage
```bash
# Check for updates without installing
sudo ./update_torrserver.sh --check

# Force update regardless of current version
sudo ./update_torrserver.sh --force

# Show help and usage information
./update_torrserver.sh --help
```

### Example Output
```bash
$ sudo ./update_torrserver.sh

[2025-06-11 14:30:15] Checking TorrServer updates...
[2025-06-11 14:30:16] Detected architecture: linux-amd64
[2025-06-11 14:30:16] Detecting TorrServer installation path...
[2025-06-11 14:30:17] Found existing binary: /opt/torrserver/TorrServer-linux-amd64
[2025-06-11 14:30:17] TorrServer path: /opt/torrserver/TorrServer-linux-amd64
[2025-06-11 14:30:17] TorrServer directory: /opt/torrserver
[2025-06-11 14:30:17] Getting latest version information...
[2025-06-11 14:30:18] Latest version on GitHub: MatriX.v1.2.3
[2025-06-11 14:30:18] Current installed version: MatriX.v1.2.2
[2025-06-11 14:30:18] New version found: MatriX.v1.2.3
[2025-06-11 14:30:19] Checking architecture support...
[2025-06-11 14:30:20] Binary found and available for architecture
[2025-06-11 14:30:20] Starting update...
[2025-06-11 14:30:21] Creating backup of current version...
[2025-06-11 14:30:22] Stopping torrserver service...
[2025-06-11 14:30:24] Downloading TorrServer version MatriX.v1.2.3 for linux-amd64...
[2025-06-11 14:30:28] Installing new version...
[2025-06-11 14:30:29] Starting torrserver service...
[2025-06-11 14:30:32] Service successfully started
[2025-06-11 14:30:32] Update completed successfully!
[2025-06-11 14:30:32] Architecture: linux-amd64
[2025-06-11 14:30:32] Version: MatriX.v1.2.2 → MatriX.v1.2.3
[2025-06-11 14:30:32] Executable path: /opt/torrserver/TorrServer-linux-amd64
```

## 🔧 Configuration

### Automatic Path Detection

#### Linux Systems
The script automatically detects your TorrServer installation using multiple methods:

1. **Running Service Detection**: Checks systemd service for current executable path
2. **Service File Analysis**: Reads systemd service file for configured path  
3. **Common Locations Search**: Looks in standard installation directories:
   - `/opt/torrserver/` (default)
   - `/usr/local/bin/`
   - `/usr/bin/`
   - `/home/*/torrserver/`
   - `/root/torrserver/`
4. **System-wide Search**: Performs comprehensive search if needed
5. **Default Fallback**: Uses `/opt/torrserver/` if no existing installation found

#### macOS Systems
The script uses macOS-specific detection methods:

1. **Running Service Detection**: Checks launchd for current executable path
2. **Plist File Analysis**: Reads launchd plist file for configured path
3. **Common Locations Search**: Looks in macOS standard directories:
   - `/usr/local/bin/` (default)
   - `/usr/local/torrserver/`
   - `/opt/torrserver/`
   - `/Applications/TorrServer/`
   - `/Users/*/torrserver/`
   - `/Users/*/Applications/TorrServer/`
4. **System-wide Search**: Performs comprehensive search if needed
5. **Default Fallback**: Uses `/usr/local/bin/` if no existing installation found

### Default Paths

#### Linux
- **Auto-detected binary location**: Varies based on existing installation
- **Fallback binary location**: `/opt/torrserver/TorrServer-{architecture}`
- **Version file**: `{detected_directory}/.version`
- **Service name**: `torrserver`
- **Service file**: `/etc/systemd/system/torrserver.service`

#### macOS
- **Auto-detected binary location**: Varies based on existing installation
- **Fallback binary location**: `/usr/local/bin/TorrServer-{architecture}`
- **Version file**: `{detected_directory}/.version`
- **Service name**: `com.torrserver.daemon`
- **Service file**: `/Library/LaunchDaemons/com.torrserver.daemon.plist`
- **Log files**: `/var/log/torrserver.log`, `/var/log/torrserver.error.log`

### Service Management

#### Linux (systemd)
```bash
# Control service
sudo systemctl start torrserver
sudo systemctl stop torrserver
sudo systemctl status torrserver
sudo systemctl enable torrserver
```

#### macOS (launchd)
```bash
# Control service
sudo launchctl load /Library/LaunchDaemons/com.torrserver.daemon.plist
sudo launchctl unload /Library/LaunchDaemons/com.torrserver.daemon.plist
sudo launchctl start com.torrserver.daemon
sudo launchctl stop com.torrserver.daemon
launchctl list | grep torrserver

# View logs
tail -f /var/log/torrserver.log
tail -f /var/log/torrserver.error.log
```

### Manual Override
You can still modify paths by editing these variables in the script:
```bash
# These are now auto-detected, but can be overridden
TORRSERVER_PATH=$(detect_torrserver_path)  # Auto-detection function
TORRSERVER_DIR=$(dirname "$TORRSERVER_PATH")
VERSION_FILE="$TORRSERVER_DIR/.version"
SERVICE_NAME="torrserver"  # Linux: "torrserver", macOS: "com.torrserver.daemon"
```

## 🛠️ Troubleshooting

### Common Issues

#### Permission Denied
```bash
ERROR: This script must be run as root (sudo)
```
**Solution**: Run with `sudo ./update_torrserver.sh`

#### Architecture Not Supported
```bash
ERROR: Unsupported architecture: mips64
```
**Solution**: Check if TorrServer provides binaries for your architecture

#### Download Failed
```bash
ERROR: Error downloading new version
```
**Solutions**:
- Check internet connection
- Verify GitHub is accessible
- Try again later (temporary server issues)

#### Service Failed to Start
```bash
WARNING: Service may not be working correctly
```
**Solutions**:
- Check service status: `systemctl status torrserver`
- View logs: `journalctl -u torrserver -f`
- Verify binary permissions: `ls -la /opt/torrserver/`

### Debug Mode
For detailed troubleshooting, you can enable debug output:
```bash
# Add debug flag to script
set -x
sudo ./update_torrserver.sh
```

## 🔄 Migration from Old Script

The new script is fully backward compatible. For existing installations:

1. **No manual migration needed** - the script detects your current setup
2. **Your data is preserved** - only the binary is updated
3. **Service configuration remains** - existing systemd service is maintained
4. **Version tracking begins** - the script will start tracking versions going forward

### First Run After Migration
```bash
$ sudo ./update_torrserver.sh

[2025-06-11 14:30:15] Checking TorrServer updates...
[2025-06-11 14:30:16] Detected architecture: linux-arm64
[2025-06-11 14:30:17] Getting latest version information...
[2025-06-11 14:30:18] Latest version on GitHub: MatriX.v1.2.3
[2025-06-11 14:30:18] WARNING: Version file not found. This may be the first installation.
[2025-06-11 14:30:18] New version found: MatriX.v1.2.3
# ... continues with normal update process
```

## 🧪 Testing

The script has been tested on:

### Linux Operating Systems
- ✅ Ubuntu 20.04, 22.04, 24.04
- ✅ Debian 10, 11, 12
- ✅ CentOS 7, 8
- ✅ Rocky Linux 8, 9
- ✅ Raspberry Pi OS (32-bit and 64-bit)

### macOS Versions
- ✅ macOS 12 Monterey (Intel & Apple Silicon)
- ✅ macOS 13 Ventura (Intel & Apple Silicon)
- ✅ macOS 14 Sonoma (Intel & Apple Silicon)
- ✅ macOS 15 Sequoia (Intel & Apple Silicon)

### Hardware Platforms
- ✅ Intel/AMD x86_64 servers and desktops
- ✅ ARM64 servers (AWS Graviton, Oracle Ampere)
- ✅ Raspberry Pi 4 (ARM64)
- ✅ Raspberry Pi 3 (ARMv7)
- ✅ Legacy x86 systems
- ✅ Intel Mac (x86_64)
- ✅ Apple Silicon Mac (M1, M2, M3 - arm64)

## 🤝 Contributing

We welcome contributions! Please feel free to submit pull requests or open issues.

### Development Setup
```bash
# Clone repository
git clone https://github.com/YouROK/TorrServer.git
cd TorrServer

# Make script executable
chmod +x update_torrserver.sh

# Test on your platform
sudo ./update_torrserver.sh --check
```

### Contribution Guidelines
- Maintain backward compatibility
- Test on multiple architectures if possible
- Follow existing code style and comments
- Update documentation for new features

## 📋 Changelog

### v2.0.0 (Current)
- ✅ **Added**: Multi-architecture auto-detection
- ✅ **Added**: Command-line interface (--help, --force, --check)
- ✅ **Added**: Smart version checking and comparison
- ✅ **Added**: Backup and rollback system
- ✅ **Added**: Architecture validation and availability checking
- ✅ **Added**: Enhanced logging with colors and timestamps
- ✅ **Added**: Automatic systemd service creation
- ✅ **Added**: Comprehensive error handling
- ✅ **Improved**: User experience and feedback
- ✅ **Fixed**: Syntax errors in original script

### v1.0.0 (Original)
- ✅ Basic TorrServer download and installation
- ✅ ARM64 architecture support only
- ✅ Simple systemd service restart

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **TorrServer Team** for creating and maintaining TorrServer
- **Community contributors** for testing and feedback
- **GitHub Actions** for release automation

---

**Made with ❤️ for the TorrServer community**