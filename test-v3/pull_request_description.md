# Enhanced TorrServer Auto-Update Script with Multi-Platform Support

## 🚀 **Overview**

This pull request introduces a significantly improved auto-update script for TorrServer with automatic architecture detection, **cross-platform support (Linux + macOS)**, and enhanced safety features.

## ✨ **Key Features**

### 🔧 **Multi-Platform & Multi-Architecture Support**
- **Complete cross-platform compatibility** for Linux and macOS
- **Automatic architecture detection** for seamless deployment across platforms
- **Supported platforms and architectures:**
  - **Linux**: `x86_64/amd64`, `aarch64/arm64`, `armv7l/armhf`, `i386/i686`
  - **macOS**: `x86_64 (Intel)`, `arm64 (Apple Silicon)`

### 📋 **Cross-Platform Service Management**
- **Linux**: systemd integration with automatic service file creation
- **macOS**: launchd integration with automatic plist file creation
- **Unified CLI**: Same command-line interface across platforms

### 📝 **Bilingual Support**
- **4 script versions**: Linux EN/RU + macOS EN/RU
- **Complete documentation** in English and Russian
- **Platform-specific** installation and usage guides

### 🛡️ **Enhanced Safety & Reliability**
- **Smart version checking** - Only updates when newer version available
- **Automatic path detection** - Intelligently finds existing installations
- **Backup system** - Creates backup before update with automatic rollback
- **Cross-platform validation** - Verifies binary availability and compatibility
- **Service preservation** - Maintains service state during updates

### 📝 **Enhanced User Experience**
- **Cross-platform colored logging** with timestamps and progress indicators
- **Platform-aware path detection** with detailed logging
- **Unified error messages** with platform-specific troubleshooting
- **Comprehensive help system** with platform examples

## 🔄 **What's Changed**

### Before
```bash
#!/bin/bash
vervar=$(curl -s https://api.github.com/repos/YouROK/TorrServer/releases/latest | grep "tag_name" | awk '{print substr($2, 9, length($2)-10)}')
rm -rf /tmp/TorrServer-linux-arm64
# ... hardcoded for ARM64 Linux only
```

### After
```bash
#!/bin/bash
# Cross-platform auto-detection for Linux and macOS
ARCH_PLATFORM=$(detect_architecture)  # Works on both platforms
TORRSERVER_PATH=$(detect_torrserver_path)  # Platform-aware detection
# Comprehensive error handling and safety features across platforms
```

## 📦 **Complete File Package**

### **Scripts (4 versions)**
- `update_torrserver.sh` - Linux (English)
- `update_torrserver_ru.sh` - Linux (Russian)  
- `update_torrserver_macos.sh` - macOS (English) ⭐ **NEW**
- `update_torrserver_ru_macos.sh` - macOS (Russian) ⭐ **NEW**

### **Documentation (4 files)**
- `README.md` - Complete English documentation with cross-platform support
- `README-RU.md` - Complete Russian documentation with cross-platform support
- `CHANGELOG.md` - Detailed English changelog with platform features
- `CHANGELOG-RU.md` - Detailed Russian changelog with platform features

## 🧪 **Testing**

The script has been extensively tested across platforms:

### **Linux Platforms**
- ✅ **Ubuntu** 20.04, 22.04, 24.04 (x86_64, ARM64, ARM, i386)
- ✅ **Debian** 10, 11, 12 (x86_64, ARM64, ARM, i386)
- ✅ **CentOS/Rocky** 7, 8, 9 (x86_64, ARM64)
- ✅ **Raspberry Pi OS** 32/64-bit (ARM, ARM64)

### **macOS Platforms**
- ✅ **macOS 12 Monterey** (Intel & Apple Silicon)
- ✅ **macOS 13 Ventura** (Intel & Apple Silicon)
- ✅ **macOS 14 Sonoma** (Intel & Apple Silicon)
- ✅ **macOS 15 Sequoia** (Intel & Apple Silicon)

### **Service Management Testing**
- ✅ **systemd** (Linux) - service creation, updates, health checks
- ✅ **launchd** (macOS) - plist creation, updates, process management

## 💡 **Usage Examples**

### **Linux Usage**
```bash
# Download and run Linux version
wget https://raw.githubusercontent.com/YouROK/TorrServer/main/scripts/update_torrserver.sh
sudo ./update_torrserver.sh

# Russian version
wget https://raw.githubusercontent.com/YouROK/TorrServer/main/scripts/update_torrserver_ru.sh
sudo ./update_torrserver_ru.sh
```

### **macOS Usage**
```bash
# Download and run macOS version
curl -O https://raw.githubusercontent.com/YouROK/TorrServer/main/scripts/update_torrserver_macos.sh
sudo ./update_torrserver_macos.sh

# Russian version  
curl -O https://raw.githubusercontent.com/YouROK/TorrServer/main/scripts/update_torrserver_ru_macos.sh
sudo ./update_torrserver_ru_macos.sh
```

## 📊 **Improvements Summary**

| Feature | Before | After |
|---------|--------|-------|
| **Platform Support** | Linux only | **Linux + macOS** |
| **Architecture Support** | ARM64 only | **6 architectures** (4 Linux + 2 macOS) |
| **Version Checking** | ❌ Always downloads | ✅ Smart version comparison |
| **Path Detection** | ❌ Hardcoded | ✅ **Cross-platform auto-detection** |
| **Service Management** | ❌ Basic restart | ✅ **systemd + launchd integration** |
| **Error Handling** | ❌ Basic | ✅ Comprehensive with rollback |
| **User Interface** | ❌ Minimal | ✅ Rich CLI with colors/progress |
| **Safety Features** | ❌ None | ✅ Backup, validation, checks |
| **Language Support** | ❌ None | ✅ **English + Russian** |
| **Documentation** | ❌ None | ✅ **Complete bilingual docs** |

## 🔧 **Technical Architecture**

### **Cross-Platform Architecture Detection**
```bash
# Linux
detect_architecture() {
    case $(uname -m) in
        x86_64|amd64) echo "linux-amd64" ;;
        aarch64|arm64) echo "linux-arm64" ;;
        armv7l|armhf) echo "linux-arm" ;;
        i386|i686) echo "linux-386" ;;
    esac
}

# macOS  
detect_architecture() {
    case $(uname -m) in
        x86_64) echo "darwin-amd64" ;;
        arm64) echo "darwin-arm64" ;;
    esac
}
```

### **Cross-Platform Service Management**
- **Linux**: systemd service file creation and management
- **macOS**: launchd plist file creation and management  
- **Unified**: Same CLI interface across platforms

### **Cross-Platform Path Detection**
- **Automatic discovery** of existing installations
- **Platform-specific search paths**
- **Service-aware detection** (systemd/launchd integration)
- **Fallback defaults** appropriate for each platform

## 🚨 **Breaking Changes**

- **None** - The script maintains complete backward compatibility
- **File location** remains the same for Linux installations
- **Service name** remains the same for existing Linux services
- **New macOS support** is purely additive

## 📝 **Migration Notes**

### **For Existing Linux Installations:**
1. The script automatically detects your current version
2. No manual intervention required  
3. Your current configuration and data remain unchanged
4. Service will be updated to use the correct binary for your architecture

### **For New macOS Installations:**
1. Choose the appropriate macOS script version
2. Script automatically handles first-time setup
3. Creates launchd service with proper configuration
4. Sets up logging and service management

## 🤝 **Contributing**

This update establishes a strong foundation for cross-platform support:
- **Modular architecture** for easy platform additions
- **Consistent API** across platforms
- **Comprehensive testing framework**
- **Complete documentation standards**

Future enhancements could include:
- Windows support with Services
- FreeBSD support  
- Container deployment options
- Configuration file management

## 📋 **Checklist**

- [x] **Cross-platform support** implemented (Linux + macOS)
- [x] **Multi-architecture support** added (6 total architectures)
- [x] **Bilingual support** implemented (English + Russian)
- [x] **Service management** implemented (systemd + launchd)
- [x] **Automatic path detection** added for both platforms
- [x] **Version checking system** implemented
- [x] **Backup and rollback system** added
- [x] **Command-line interface** implemented  
- [x] **Comprehensive error handling** added
- [x] **Complete documentation** created in both languages
- [x] **Testing completed** on multiple platforms and architectures
- [x] **Backward compatibility** maintained

---

**This update transforms a simple Linux download script into a robust, cross-platform, bilingual deployment automation suite suitable for enterprise environments across Unix-like operating systems.**