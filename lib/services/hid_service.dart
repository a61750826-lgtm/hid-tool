import 'dart:async';
import 'package:flutter/services.dart';

class HidReport {
  final int modifier;
  final int keycode;

  HidReport({this.modifier = 0, this.keycode = 0});

  List<int> toBytes() => [modifier, 0, keycode, 0, 0, 0, 0, 0];
  static List<int> releaseBytes() => [0, 0, 0, 0, 0, 0, 0, 0];
}

class HidService {
  static final HidService _instance = HidService._internal();
  factory HidService() => _instance;
  HidService._internal();

  bool isConnected = true;
  bool isRooted = true;
  String currentDevice = "/dev/hidg0";
  String targetCpuAbi = "arm64-v8a";

  // USB HID Scancode mapping (USB HID Usage Table Page 0x07)
  static final Map<String, int> _scancodes = {
    'a': 0x04, 'b': 0x05, 'c': 0x06, 'd': 0x07, 'e': 0x08, 'f': 0x09,
    'g': 0x0A, 'h': 0x0B, 'i': 0x0C, 'j': 0x0D, 'k': 0x0E, 'l': 0x0F,
    'm': 0x10, 'n': 0x11, 'o': 0x12, 'p': 0x13, 'q': 0x14, 'r': 0x15,
    's': 0x16, 't': 0x17, 'u': 0x18, 'v': 0x19, 'w': 0x1A, 'x': 0x1B,
    'y': 0x1C, 'z': 0x1D, '1': 0x1E, '2': 0x1F, '3': 0x20, '4': 0x21,
    '5': 0x22, '6': 0x23, '7': 0x24, '8': 0x25, '9': 0x26, '0': 0x27,
    'enter': 0x28, 'esc': 0x29, 'backspace': 0x2A, 'tab': 0x2B, 'space': 0x2C,
    '-': 0x2D, '=': 0x2E, '[': 0x2F, ']': 0x30, '\\': 0x31, ';': 0x33,
    '\'': 0x34, '`': 0x35, ',': 0x36, '.': 0x37, '/': 0x38,
    'capslock': 0x39, 'f1': 0x3A, 'f2': 0x3B, 'f3': 0x3C, 'f4': 0x3D,
    'f5': 0x3E, 'f6': 0x3F, 'f7': 0x40, 'f8': 0x41, 'f9': 0x42, 'f10': 0x43,
    'f11': 0x44, 'f12': 0x45, 'printscreen': 0x46, 'scrolllock': 0x47,
    'pause': 0x48, 'insert': 0x49, 'home': 0x4A, 'pageup': 0x4B, 'delete': 0x4C,
    'end': 0x4D, 'pagedown': 0x4E, 'right': 0x4F, 'left': 0x50, 'down': 0x51,
    'up': 0x52,
  };

  // Modifiers
  static const int modCtrl = 0x01;
  static const int modShift = 0x02;
  static const int modAlt = 0x04;
  static const int modGui = 0x08; // Windows / Command Key

  int activeModifiers = 0;

  void toggleModifier(int mask) {
    activeModifiers ^= mask;
    HapticFeedback.lightImpact();
  }

  bool isModifierActive(int mask) => (activeModifiers & mask) != 0;

  Future<void> sendKey(String key) async {
    HapticFeedback.lightImpact();
    int code = _scancodes[key.toLowerCase()] ?? 0;
    if (code == 0) return;

    int mod = activeModifiers;
    // Auto-shift for uppercase
    if (key.length == 1 && key.toUpperCase() == key && key.toLowerCase() != key) {
      mod |= modShift;
    }

    // Byte report: [modifier, 0, keycode, 0, 0, 0, 0, 0]
    // In production root environment, write to /dev/hidg0 via Process.run("su", ["-c", "..."])
  }

  Future<void> sendMouseMove(double dx, double dy, int buttons, int wheel) async {
    int relX = dx.clamp(-127, 127).toInt();
    int relY = dy.clamp(-127, 127).toInt();
    int relWheel = wheel.clamp(-127, 127);
    // Mouse report: [buttons, relX, relY, relWheel] to /dev/hidg1
  }

  Future<void> sendMouseClick(int buttonMask) async {
    HapticFeedback.mediumImpact();
    // Press
    // Release
  }
}
