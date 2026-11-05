# HID Tool — Google Material 3 Android Interface

An ultra-responsive, premium mobile app for Android providing USB HID, Bluetooth HID, and Magisk Boot Persistence interfaces.

## Features
* **USB HID Hub**:
  * **USB Keyboard**: Full phone-screen physical keyboard with modifiers (Ctrl, Alt, Win, Shift, Tab, Esc) and haptic feedback.
  * **USB Touchpad**: Frosted trackpad with gestures, left/right clicks, sensitivity selector, and two-finger scroll.
  * **Payloads Studio**: BadUSB & DuckyScript injection engine with pre-loaded library, syntax viewer, and emergency kill-switch.
  * **USB Drive**: Mount ISO/IMG disk images as virtual CD-ROMs or removable flash drives.
  * **Device Identity Spoofer**: Custom VID/PID presets (Dell, Apple, Logitech, Lenovo).
* **Bluetooth HID**: Wireless keyboard and mouse controller via Android 11+ AOSP BluetoothHidDevice.
* **Boot & Autorun**: Magisk service script generator (`/data/adb/service.d/hid_enabler.sh`) for persistent `/dev/hidg0` creation on device boot.

## Compilation & Installation
* **Cloud Compiling**: Automatically built via GitHub Actions (`.github/workflows/build_apk.yml`).
* **Target Architecture**: Strictly modern `arm64-v8a` (no legacy 32-bit binaries).
* **Target OS**: Android 11+ (API 30–34).
