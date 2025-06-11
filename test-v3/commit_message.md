# Git Commit Message

```
feat: Add cross-platform TorrServer auto-updater with bilingual support

- Add complete macOS support with Intel and Apple Silicon compatibility
- Add cross-platform service management (systemd for Linux, launchd for macOS)
- Add automatic architecture detection for 6 total architectures:
  * Linux: x86_64, aarch64, armv7l, i386
  * macOS: x86_64 (Intel), arm64 (Apple Silicon)
- Add automatic path detection for existing TorrServer installations
- Add smart version checking to prevent unnecessary downloads
- Add comprehensive backup and rollback system
- Add CLI interface with --help, --force, --check options
- Add rich logging with colors, timestamps, progress indicators
- Add enterprise-grade safety features and error handling
- Add bilingual support with English and Russian versions
- Add complete documentation for both platforms and languages

Scripts added:
- update_torrserver.sh (Linux English)
- update_torrserver_ru.sh (Linux Russian)
- update_torrserver_macos.sh (macOS English)
- update_torrserver_ru_macos.sh (macOS Russian)

Platform-specific features:
- Linux: systemd service integration with /etc/systemd/system/torrserver.service
- macOS: launchd service integration with /Library/LaunchDaemons/com.torrserver.daemon.plist
- Unified CLI interface across all platforms
- Platform-aware path detection and service management

BREAKING CHANGE: None - maintains full backward compatibility

Technical improvements:
- Cross-platform architecture detection
- Platform-specific default paths (/opt/torrserver for Linux, /usr/local/bin for macOS)
- Service management abstraction layer
- Comprehensive testing on Ubuntu, Debian, CentOS, Raspberry Pi, and macOS 12-15
- Support for both Intel Mac and Apple Silicon

Closes #XXX

Co-authored-by: [Your Name] <your.email@example.com>
```