# Cross-Platform Bilingual TorrServer Auto-Updater Scripts

## 📁 **Recommended File Structure**

```
TorrServer/
├── scripts/
│   ├── update_torrserver.sh          # Linux English (main)
│   ├── update_torrserver_ru.sh       # Linux Russian
│   ├── update_torrserver_macos.sh    # macOS English (NEW)
│   ├── update_torrserver_ru_macos.sh # macOS Russian (NEW)
│   ├── README.md                     # English documentation
│   ├── README-RU.md                  # Russian documentation
│   ├── CHANGELOG.md                  # English changelog
│   ├── CHANGELOG-RU.md               # Russian changelog
│   └── examples/
│       ├── linux/
│       │   ├── basic_usage.sh        # Linux English examples
│       │   └── basic_usage_ru.sh     # Linux Russian examples
│       └── macos/
│           ├── basic_usage.sh        # macOS English examples
│           └── basic_usage_ru.sh     # macOS Russian examples
```

## 🌐 **Cross-Platform Language Matrix**

### **Linux Versions**
| Language | Script Name | Target Audience |
|----------|-------------|-----------------|
| **English** | `update_torrserver.sh` | International Linux users |
| **Russian** | `update_torrserver_ru.sh` | Russian-speaking Linux users |

### **macOS Versions**
| Language | Script Name | Target Audience |
|----------|-------------|-----------------|
| **English** | `update_torrserver_macos.sh` | International macOS users |
| **Russian** | `update_torrserver_ru_macos.sh` | Russian-speaking macOS users |

## 🔧 **Platform-Specific Differences**

| Feature | Linux Versions | macOS Versions |
|---------|----------------|----------------|
| **Service Management** | `systemd` with `systemctl` | `launchd` with `launchctl` |
| **Service Files** | `/etc/systemd/system/torrserver.service` | `/Library/LaunchDaemons/com.torrserver.daemon.plist` |
| **Default Path** | `/opt/torrserver/` | `/usr/local/bin/` |
| **Architecture Detection** | `linux-amd64`, `linux-arm64`, `linux-arm`, `linux-386` | `darwin-amd64`, `darwin-arm64` |
| **Download Tool** | `wget` | `curl` |
| **Service Name** | `torrserver` | `com.torrserver.daemon` |
| **Log Files** | `journalctl -u torrserver` | `/var/log/torrserver.log` |

## 🔧 **Key Differences**

| Feature | English Version | Russian Version |
|---------|----------------|-----------------|
| **Comments** | `# Architecture detection function` | `# Функция определения архитектуры` |
| **Log Messages** | `"Detected architecture: $ARCH_PLATFORM"` | `"Определена архитектура: $ARCH_PLATFORM"` |
| **Error Messages** | `"Unsupported architecture"` | `"Неподдерживаемая архитектура"` |
| **Help Text** | `"Show this help information"` | `"Показать справочную информацию"` |
| **Progress Updates** | `"Downloading TorrServer version..."` | `"Скачивание TorrServer версии..."` |

## 🚀 **Platform-Specific Usage Instructions**

### **For Linux Users**

#### **English-speaking Linux Users**
```bash
# Download Linux English version
wget https://raw.githubusercontent.com/YouROK/TorrServer/main/scripts/update_torrserver.sh

# Make executable and run
chmod +x update_torrserver.sh
sudo ./update_torrserver.sh
```

#### **Russian-speaking Linux Users**
```bash
# Download Linux Russian version
wget https://raw.githubusercontent.com/YouROK/TorrServer/main/scripts/update_torrserver_ru.sh

# Make executable and run
chmod +x update_torrserver_ru.sh
sudo ./update_torrserver_ru.sh
```

### **For macOS Users**

#### **English-speaking macOS Users**
```bash
# Download macOS English version
curl -O https://raw.githubusercontent.com/YouROK/TorrServer/main/scripts/update_torrserver_macos.sh

# Make executable and run
chmod +x update_torrserver_macos.sh
sudo ./update_torrserver_macos.sh
```

#### **Russian-speaking macOS Users**
```bash
# Download macOS Russian version
curl -O https://raw.githubusercontent.com/YouROK/TorrServer/main/scripts/update_torrserver_ru_macos.sh

# Make executable and run
chmod +x update_torrserver_ru_macos.sh
sudo ./update_torrserver_ru_macos.sh
```

## 📋 **Cross-Platform Feature Implementation**

### **Shared Features (All 4 Scripts)**
- ✅ **Architecture Detection**: Automatic for respective platforms
- ✅ **Version Checking**: Smart updates only when needed
- ✅ **Path Detection**: Platform-aware automatic discovery
- ✅ **Backup/Rollback**: Complete safety system
- ✅ **CLI Interface**: Consistent `--help`, `--force`, `--check`
- ✅ **Colored Logging**: Rich output with timestamps
- ✅ **Error Handling**: Comprehensive with troubleshooting

### **Platform-Specific Features**

#### **Linux-Specific (systemd)**
```bash
# Service management examples
sudo systemctl start torrserver
sudo systemctl stop torrserver
sudo systemctl status torrserver
sudo systemctl enable torrserver

# View logs
sudo journalctl -u torrserver -f
```

#### **macOS-Specific (launchd)**
```bash
# Service management examples
sudo launchctl load /Library/LaunchDaemons/com.torrserver.daemon.plist
sudo launchctl unload /Library/LaunchDaemons/com.torrserver.daemon.plist
sudo launchctl start com.torrserver.daemon
sudo launchctl stop com.torrserver.daemon

# View logs
tail -f /var/log/torrserver.log
tail -f /var/log/torrserver.error.log
```

## 📋 **Implementation Strategy**

### **Option 1: Separate Files (Recommended)**
- Maintain two distinct script files
- Better for users who prefer their native language
- Easier maintenance and updates
- Clear separation of concerns

### **Option 2: Single File with Language Detection**
```bash
# Detect system language and show appropriate messages
LANG_CODE=$(echo $LANG | cut -d'_' -f1)
case $LANG_CODE in
    ru) MSG_DETECTED="Определена архитектура" ;;
    *) MSG_DETECTED="Detected architecture" ;;
esac
```

### **Option 3: Language Parameter**
```bash
# Add language parameter
./update_torrserver.sh --lang=en
./update_torrserver.sh --lang=ru
```

## 🛠️ **Maintenance Considerations**

### **Advantages of Bilingual Approach**
- ✅ **Better User Experience**: Native language support
- ✅ **Wider Adoption**: Accessible to more users
- ✅ **Regional Compliance**: Meets local requirements
- ✅ **Community Growth**: Encourages local contributions

### **Maintenance Strategy**
1. **Primary Development**: English version as the main branch
2. **Translation Sync**: Keep Russian version synchronized
3. **Feature Parity**: Ensure both versions have identical functionality
4. **Testing**: Test both versions on respective language systems

## 📖 **Documentation Structure**

### **English Documentation**
- `README.md` - Complete feature documentation
- `CHANGELOG.md` - Version history and updates
- Examples with English output samples

### **Russian Documentation**
- `README-RU.md` - Полная документация возможностей
- `CHANGELOG-RU.md` - История версий и обновлений
- Examples with Russian output samples

## 🌍 **Target Audiences**

### **English Version Users**
- International developers and system administrators
- Users in English-speaking countries
- Corporate environments with English as primary language
- Open-source contributors globally

### **Russian Version Users**
- Russian-speaking system administrators
- Home users in CIS countries
- Educational institutions in Russian-speaking regions
- Local hosting providers and IT companies

## 📊 **Pull Request Strategy**

### **For GitHub Submission**
```bash
# Commit all platform and language versions together
git add scripts/update_torrserver.sh           # Linux English
git add scripts/update_torrserver_ru.sh        # Linux Russian
git add scripts/update_torrserver_macos.sh     # macOS English  
git add scripts/update_torrserver_ru_macos.sh  # macOS Russian
git add scripts/README.md                      # English docs
git add scripts/README-RU.md                   # Russian docs
git add scripts/CHANGELOG.md                   # English changelog
git add scripts/CHANGELOG-RU.md                # Russian changelog

git commit -m "feat: Add cross-platform bilingual TorrServer auto-updater

- Complete Linux support (English + Russian versions)
- Complete macOS support (English + Russian versions)  
- Support for 6 total architectures across platforms
- Cross-platform service management (systemd + launchd)
- Unified CLI interface with consistent functionality
- Complete bilingual documentation for both platforms
- Automatic path detection and version management
- Enterprise-grade safety and error handling

BREAKING CHANGE: None - maintains full backward compatibility"
```

## 🎯 **Target Audiences**

### **Linux English Version Users**
- International developers and system administrators
- Corporate Linux environments
- Open-source contributors globally
- Educational institutions with English curriculum

### **Linux Russian Version Users**  
- Russian-speaking system administrators
- CIS region home users and businesses
- Local hosting providers in Russian-speaking countries
- Educational institutions in Russian-speaking regions

### **macOS English Version Users**
- International Mac developers and users
- Corporate macOS environments
- Creative professionals using Mac
- Students and educators with Mac computers

### **macOS Russian Version Users**
- Russian-speaking Mac users and developers
- Creative professionals in CIS region
- Mac users in Russian-speaking educational institutions
- Russian-speaking entrepreneurs and small businesses

## 🌍 **Global Impact**

### **Geographic Coverage**
- **North America**: Linux/macOS English versions
- **Europe**: Linux/macOS English versions  
- **CIS Region**: Linux/macOS Russian versions
- **Asia**: Linux/macOS English versions (with potential for future localization)
- **Developers Worldwide**: All versions for cross-platform development

### **Use Case Coverage**
- **Home Users**: Simple, localized interface in native language
- **SMB**: Professional tools with enterprise safety features
- **Enterprise**: Cross-platform deployment with unified management
- **Education**: Accessible in local languages for learning
- **Development**: Consistent API across platforms for DevOps

## ✅ **Best Practices for Cross-Platform Bilingual Maintenance**

### **Code Synchronization**
- Keep identical logic across all 4 versions
- Update all platform/language combinations simultaneously  
- Use version control branching for coordinated releases
- Test all versions before any release

### **Translation and Localization Quality**
- Maintain consistent technical terminology across languages
- Use native language conventions for each platform
- Keep error messages actionable in target language
- Preserve technical accuracy across all translations

### **Platform Consistency**
- Ensure feature parity across Linux and macOS versions
- Maintain consistent CLI behavior regardless of platform
- Provide equivalent functionality using platform-native tools
- Document platform differences clearly

### **Testing Strategy**
- Test each language version on its target platform
- Verify cross-platform functionality consistency
- Test service management on both systemd and launchd
- Validate architecture detection across all supported hardware

---

**This cross-platform bilingual approach significantly expands accessibility and adoption potential, making TorrServer deployment welcoming to users across different operating systems, hardware architectures, and linguistic preferences worldwide.**