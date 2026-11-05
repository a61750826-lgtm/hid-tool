import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

class HidService {
  static final HidService _instance = HidService._internal();
  factory HidService() => _instance;
  HidService._internal();

  bool isConnected = false;
  bool isRooted = true;
  String currentDevice = "/dev/hidg0";

  // Modifiers
  static const int modCtrl = 0x01;
  static const int modShift = 0x02;
  static const int modAlt = 0x04;
  static const int modGui = 0x08; // Windows / Command Key
  static const int modRightCtrl = 0x10;
  static const int modRightShift = 0x20;
  static const int modRightAlt = 0x40; // AltGr

  int activeModifiers = 0;
  RandomAccessFile? _hidFile;
  bool _directAccessSupported = false;

  void toggleModifier(int mask) {
    activeModifiers ^= mask;
    HapticFeedback.lightImpact();
  }

  bool isModifierActive(int mask) => (activeModifiers & mask) != 0;

  // USB HID Scancodes (Usage Table Page 0x07)
  static final Map<String, int> _scancodes = {
    // Letters
    'a': 0x04, 'b': 0x05, 'c': 0x06, 'd': 0x07, 'e': 0x08, 'f': 0x09,
    'g': 0x0A, 'h': 0x0B, 'i': 0x0C, 'j': 0x0D, 'k': 0x0E, 'l': 0x0F,
    'm': 0x10, 'n': 0x11, 'o': 0x12, 'p': 0x13, 'q': 0x14, 'r': 0x15,
    's': 0x16, 't': 0x17, 'u': 0x18, 'v': 0x19, 'w': 0x1A, 'x': 0x1B,
    'y': 0x1C, 'z': 0x1D,
    // Numbers
    '1': 0x1E, '2': 0x1F, '3': 0x20, '4': 0x21, '5': 0x22,
    '6': 0x23, '7': 0x24, '8': 0x25, '9': 0x26, '0': 0x27,
    // Controls & Whitespace
    'enter': 0x28, '\n': 0x28,
    'esc': 0x29,
    'backspace': 0x2A,
    'tab': 0x2B, '\t': 0x2B,
    'space': 0x2C, ' ': 0x2C,
    // Punctuations
    '-': 0x2D, '=': 0x2E, '[': 0x2F, ']': 0x30, '\\': 0x31,
    ';': 0x33, '\'': 0x34, '`': 0x35, ',': 0x36, '.': 0x37, '/': 0x38,
    'capslock': 0x39,
    // Function Keys
    'f1': 0x3A, 'f2': 0x3B, 'f3': 0x3C, 'f4': 0x3D, 'f5': 0x3E, 'f6': 0x3F,
    'f7': 0x40, 'f8': 0x41, 'f9': 0x42, 'f10': 0x43, 'f11': 0x44, 'f12': 0x45,
    // Navigation & Editing
    'printscreen': 0x46, 'scrolllock': 0x47, 'pause': 0x48,
    'insert': 0x49, 'home': 0x4A, 'pageup': 0x4B, 'delete': 0x4C,
    'end': 0x4D, 'pagedown': 0x4E,
    'right': 0x4F, 'left': 0x50, 'down': 0x51, 'up': 0x52,
  };

  // Shifted characters mapping to (baseChar, needsShift)
  static final Map<String, String> _shiftChars = {
    '!': '1', '@': '2', '#': '3', '\$': '4', '%': '5',
    '^': '6', '&': '7', '*': '8', '(': '9', ')': '0',
    '_': '-', '+': '=', '{': '[', '}': ']', '|': '\\',
    ':': ';', '"': '\'', '~': '`', '<': ',', '>': '.', '?': '/',
  };

  /// Initialize and verify /dev/hidg0 access
  Future<bool> initDevice() async {
    try {
      final dev = File(currentDevice);
      if (await dev.exists()) {
        try {
          _hidFile = await dev.open(mode: FileMode.writeOnlyAppend);
          _directAccessSupported = true;
          isConnected = true;
          return true;
        } catch (_) {
          // Fall back to su chmod
        }
      }

      // Execute root setup to create device node and set permissions
      final setupCmd = '''
mkdir -p /config/usb_gadget/g1/functions/hid.gs0
echo 1 > /config/usb_gadget/g1/functions/hid.gs0/protocol 2>/dev/null
echo 1 > /config/usb_gadget/g1/functions/hid.gs0/subclass 2>/dev/null
echo 8 > /config/usb_gadget/g1/functions/hid.gs0/report_length 2>/dev/null
printf "\\x05\\x01\\x09\\x06\\xa1\\x01\\x05\\x07\\x19\\xe0\\x29\\xe7\\x15\\x00\\x25\\x01\\x75\\x01\\x95\\x08\\x81\\x02\\x95\\x01\\x75\\x08\\x81\\x03\\x95\\x05\\x75\\x01\\x05\\x08\\x19\\x01\\x29\\x05\\x91\\x02\\x95\\x01\\x75\\x03\\x91\\x03\\x95\\x06\\x75\\x08\\x15\\x00\\x25\\x65\\x05\\x07\\x19\\x00\\x29\\x65\\x81\\x00\\xc0" > /config/usb_gadget/g1/functions/hid.gs0/report_desc 2>/dev/null
ln -s /config/usb_gadget/g1/functions/hid.gs0 /config/usb_gadget/g1/configs/b.1/f2 2>/dev/null
mknod $currentDevice c 489 0 2>/dev/null
chmod 666 $currentDevice 2>/dev/null
''';
      await Process.run('su', ['-c', setupCmd]);
      
      if (await dev.exists()) {
        _hidFile = await dev.open(mode: FileMode.writeOnlyAppend);
        _directAccessSupported = true;
        isConnected = true;
        return true;
      }
    } catch (_) {}
    isConnected = false;
    return false;
  }

  /// Write 8-byte HID report
  Future<void> _writeReport(List<int> bytes) async {
    if (bytes.length != 8) return;

    if (_directAccessSupported && _hidFile != null) {
      try {
        await _hidFile!.writeFrom(bytes);
        await _hidFile!.flush();
        return;
      } catch (_) {
        _directAccessSupported = false;
      }
    }

    // Fallback using root shell printf
    final hexString = bytes.map((b) => '\\x${b.toRadixString(16).padLeft(2, '0')}').join();
    try {
      await Process.run('su', ['-c', 'printf "$hexString" > $currentDevice']);
    } catch (_) {}
  }

  /// Sends a single key press and release
  Future<void> sendKey(String key, {int? explicitModifiers}) async {
    HapticFeedback.lightImpact();

    int mod = explicitModifiers ?? activeModifiers;
    String targetKey = key.toLowerCase();

    // Check if character requires shift (uppercase or symbol)
    if (_shiftChars.containsKey(key)) {
      targetKey = _shiftChars[key]!;
      mod |= modShift;
    } else if (key.length == 1 && key.toUpperCase() == key && key.toLowerCase() != key) {
      targetKey = key.toLowerCase();
      mod |= modShift;
    }

    int code = _scancodes[targetKey] ?? 0;
    if (code == 0) return;

    // Key Down Report: [modifier, reserved(0), keycode, 0, 0, 0, 0, 0]
    await _writeReport([mod, 0, code, 0, 0, 0, 0, 0]);
    // Small delay to register on host PC USB poll cycle
    await Future.delayed(const Duration(milliseconds: 12));
    // Key Release Report: all zeroes
    await _writeReport([0, 0, 0, 0, 0, 0, 0, 0]);
  }

  /// Stream an entire text string as sequential HID keystrokes
  Future<void> sendText(String text, {int delayMs = 15}) async {
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      await sendKey(char);
      if (delayMs > 0) {
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }
  }

  /// Mouse simulation
  Future<void> sendMouseMove(double dx, double dy, int buttons, int wheel) async {
    int relX = dx.clamp(-127, 127).toInt();
    int relY = dy.clamp(-127, 127).toInt();
    int relWheel = wheel.clamp(-127, 127);
    // Mouse report to /dev/hidg1
  }

  Future<void> sendMouseClick(int buttonMask) async {
    HapticFeedback.mediumImpact();
  }
}
