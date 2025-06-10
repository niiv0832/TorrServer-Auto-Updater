# Changelog

All notable changes to the TorrServer Auto-Updater script will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-06-11

### 🚀 Added
- **Multi-Architecture Support**: Automatic detection and support for x86_64, aarch64, armv7l, and i386 architectures
- **Command Line Interface**: 
  - `--help` flag for usage information
  - `--force` flag for forced updates
  - `--check` flag for update checking without installation
- **Smart Version Management**: 
  - Version comparison system to prevent unnecessary downloads
  - Version tracking with persistent storage in `/opt/torrserver/.version`
- **Enhanced Safety Features**:
  - Automatic backup creation before updates
  - Rollback functionality on update failure
  - Binary integrity validation
  - Architecture compatibility verification
- **Improved User Experience**:
  - Colored logging with timestamps
  - Progress indicators for all operations
  - Detailed error messages with troubleshooting information
  - Operation summaries with before/after version info
- **Service Management**:
  - Proper systemd service handling
  - Automatic service file creation if missing
  - Service health checks post-update
- **Error Handling**:
  - Comprehensive error detection and reporting
  - Graceful degradation on failures
  - Detailed logging for troubleshooting

### 🔧 Changed
- **Architecture Detection**: Replaced hardcoded ARM64 binary with automatic architecture detection
- **Download Process**: Enhanced with validation and error handling
- **Installation Process**: Added backup and rollback mechanisms
- **Logging System**: Upgraded from basic echo statements to structured, colored logging
- **Script Structure**: Modularized into functions for better maintainability

### 🛠️ Fixed
- **Syntax Errors**: Corrected awk command syntax and quote handling
- **Path Handling**: Improved file path management and validation
- **Error Recovery**: Added proper error handling and recovery mechanisms
- **Service Management**: Fixed service stop/start sequence and validation

### 🔄 Technical Details

#### Architecture Detection Logic
```bash
detect_architecture() {
    local arch=$(uname -m)
    case $arch in
        x86_64|amd64) echo "linux-amd64" ;;
        aarch64|arm64) echo "linux-arm64" ;;
        armv7l|armhf) echo "linux-arm" ;;
        i386|i686) echo "linux-386" ;;
        *) error "Unsupported architecture: $arch"; exit 1 ;;
    esac
}
```

#### Version Comparison System
- Stores current version in `/opt/torrserver/.version`
- Compares with latest GitHub release
- Skips download if versions match (unless `--force` is used)

#### Backup and Recovery
- Creates `.backup` files before overwriting
- Automatic rollback on download or installation failure
- Preserves service state during updates

#### Enhanced Error Handling
- Pre-flight checks for permissions and dependencies
- Download validation with file size and content checks
- Service health verification post-update
- Detailed error messages with suggested solutions

### 📊 Performance Improvements
- **Reduced Network Calls**: Only downloads when necessary
- **Faster Updates**: Skips unnecessary operations when already up-to-date
- **Better Resource Usage**: Improved temporary file handling

### 🧪 Testing Coverage
- **Platforms Tested**: Ubuntu, Debian, CentOS, Rocky Linux, Raspberry Pi OS
- **Architectures Tested**: x86_64, aarch64, armv7l, i386
- **Scenarios Tested**: 
  - Fresh installation
  - Version upgrades
  - Forced updates
  - Network failure recovery
  - Permission issues
  - Service management

### 📈 Compatibility
- **Backward Compatible**: Works with existing TorrServer installations
- **Migration**: Automatic detection and migration of existing setups
- **No Breaking Changes**: Maintains all existing functionality

---

## [1.0.0] - Original Release

### Added
- Basic TorrServer download functionality
- ARM64 architecture support
- Simple systemd service restart
- GitHub API integration for version detection

### Technical Specifications
- **Target Architecture**: ARM64 only
- **Installation Path**: `/opt/torrserver`
- **Service Management**: Basic restart functionality
- **Error Handling**: Minimal

### Known Issues (Resolved in v2.0.0)
- Hardcoded architecture (ARM64 only)
- No version checking (always downloads)
- Limited error handling
- Syntax errors in awk commands
- No backup or rollback functionality

---

## Migration Notes

### From v1.0.0 to v2.0.0
- **Automatic Migration**: No manual steps required
- **Data Preservation**: All existing data and configurations preserved
- **Service Continuity**: Service remains functional during upgrade
- **Version Tracking**: Begins tracking versions after first run

### Upgrade Process
1. Replace old script with new version
2. Run: `sudo ./update_torrserver.sh`
3. Script automatically detects existing installation
4. Creates version file for future tracking
5. Continues with normal update process

---

## Future Roadmap

### Planned Features (v2.1.0)
- [ ] Configuration file support
- [ ] Multiple instance management
- [ ] Automated scheduling with cron integration
- [ ] Docker container support
- [ ] Update notifications
- [ ] Rollback to previous versions

### Under Consideration
- [ ] GUI version for desktop environments
- [ ] Integration with package managers
- [ ] Support for custom repositories
- [ ] Prometheus metrics integration
- [ ] Web-based management interface

---

**For detailed technical documentation, see [README.md](README.md)**
