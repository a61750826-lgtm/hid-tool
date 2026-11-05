import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/hid_service.dart';
import '../theme/app_theme.dart';

enum KeyboardMode { laptop, phoneIme }

class UsbKeyboardScreen extends StatefulWidget {
  const UsbKeyboardScreen({super.key});
  @override
  State<UsbKeyboardScreen> createState() => _UsbKeyboardScreenState();
}

class _UsbKeyboardScreenState extends State<UsbKeyboardScreen> {
  final _hid = HidService();
  KeyboardMode _mode = KeyboardMode.laptop;

  // Modifiers state
  bool _ctrl = false;
  bool _alt = false;
  bool _shift = false;
  bool _gui = false;
  bool _caps = false;

  final List<String> _keystrokeLog = [];
  final TextEditingController _imeController = TextEditingController();
  final FocusNode _imeFocus = FocusNode();
  String _lastImeText = "";

  @override
  void initState() {
    super.initState();
    _hid.initDevice();
  }

  @override
  void dispose() {
    _imeController.dispose();
    _imeFocus.dispose();
    super.dispose();
  }

  void _recordKey(String label) {
    setState(() {
      if (_keystrokeLog.length >= 8) _keystrokeLog.removeAt(0);
      final mods = <String>[];
      if (_ctrl) mods.add('Ctrl');
      if (_alt) mods.add('Alt');
      if (_shift) mods.add('Shift');
      if (_gui) mods.add('Win');
      final prefix = mods.isEmpty ? '' : '${mods.join('+')}+';
      _keystrokeLog.add('$prefix$label');
    });
  }

  void _onKeyPress(String key, {String? display}) {
    final label = display ?? key;
    _recordKey(label);
    _hid.sendKey(key);

    // If shift was temporarily on (not locked), reset it after one keypress
    if (_shift) {
      setState(() {
        _shift = false;
        _hid.toggleModifier(HidService.modShift);
      });
    }
  }

  void _onImeChanged(String value) {
    if (value.length > _lastImeText.length) {
      // New characters typed or pasted
      final newChars = value.substring(_lastImeText.length);
      for (int i = 0; i < newChars.length; i++) {
        final c = newChars[i];
        _recordKey(c == ' ' ? 'Space' : (c == '\n' ? 'Enter' : c));
        _hid.sendKey(c);
      }
    } else if (value.length < _lastImeText.length) {
      // Backspace pressed
      _recordKey('⌫');
      _hid.sendKey('backspace');
    }
    _lastImeText = value;
  }

  Future<void> _pasteAndSend() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null && data!.text!.isNotEmpty) {
      HapticFeedback.mediumImpact();
      _recordKey('PASTE (${data.text!.length} chars)');
      await _hid.sendText(data.text!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('USB Keyboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded, size: 20),
            tooltip: 'Clear history',
            onPressed: () => setState(() => _keystrokeLog.clear()),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Mode Selector Bar (Laptop vs Phone Keyboard)
            _buildModeSelector(),

            // Live Keystroke Monitor Strip
            _buildStatusMonitor(),

            // Keyboard Body
            Expanded(
              child: _mode == KeyboardMode.laptop
                  ? _buildLaptopKeyboard()
                  : _buildPhoneKeyboard(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.outlineVariant),
        ),
        padding: const EdgeInsets.all(3),
        child: Row(
          children: [
            Expanded(
              child: _modeTab(
                title: '💻 Laptop Keyboard',
                active: _mode == KeyboardMode.laptop,
                onTap: () {
                  HapticFeedback.selectionClick();
                  _imeFocus.unfocus();
                  setState(() => _mode = KeyboardMode.laptop);
                },
              ),
            ),
            Expanded(
              child: _modeTab(
                title: '📱 Phone Keyboard',
                active: _mode == KeyboardMode.phoneIme,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _mode = KeyboardMode.phoneIme);
                  _imeFocus.requestFocus();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeTab({required String title, required bool active, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppTheme.primaryBlue.withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          border: active ? Border.all(color: AppTheme.primaryBlue.withOpacity(0.4)) : null,
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? AppTheme.primaryBlue : AppTheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusMonitor() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.6)),
        ),
        child: Row(
          children: [
            Container(
              width: 7, height: 7,
              decoration: const BoxDecoration(
                color: AppTheme.successGreen,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _keystrokeLog.isEmpty
                    ? 'USB HID Active · Output stream: /dev/hidg0'
                    : _keystrokeLog.join('  ›  '),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: AppTheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // MODE 1: LAPTOP KEYBOARD (True Chiclet Laptop Layout)
  // -------------------------------------------------------------
  Widget _buildLaptopKeyboard() {
    final isShifted = _shift ^ _caps;

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
      child: Column(
        children: [
          // Row 0: Esc + Function Row
          _buildFunctionRow(),

          // Row 1: Numbers & Symbols
          _buildKeyRow([
            _keyDef(isShifted ? '~' : '`', isShifted ? '~' : '`'),
            _keyDef('1', '!'), _keyDef('2', '@'), _keyDef('3', '#'),
            _keyDef('4', '\$'), _keyDef('5', '%'), _keyDef('6', '^'),
            _keyDef('7', '&'), _keyDef('8', '*'), _keyDef('9', '('),
            _keyDef('0', ')'), _keyDef('-', '_'), _keyDef('=', '+'),
            _keyDef('backspace', '⌫', flex: 1.6, specialColor: AppTheme.surfaceContainerHighest),
          ], isShifted),

          // Row 2: Tab + QWERTY
          _buildKeyRow([
            _keyDef('tab', 'Tab', flex: 1.4, specialColor: AppTheme.surfaceContainerHighest),
            _keyDef('q', 'Q'), _keyDef('w', 'W'), _keyDef('e', 'E'),
            _keyDef('r', 'R'), _keyDef('t', 'T'), _keyDef('y', 'Y'),
            _keyDef('u', 'U'), _keyDef('i', 'I'), _keyDef('o', 'O'),
            _keyDef('p', 'P'), _keyDef('[', '{'), _keyDef(']', '}'),
            _keyDef('\\', '|', flex: 1.1),
          ], isShifted),

          // Row 3: CapsLock + Home Row + Enter
          _buildKeyRow([
            _keyDef('capslock', 'Caps', flex: 1.6, isActive: _caps, onTap: () {
              setState(() {
                _caps = !_caps;
                _onKeyPress('capslock', display: 'CAPS');
              });
            }),
            _keyDef('a', 'A'), _keyDef('s', 'S'), _keyDef('d', 'D'),
            _keyDef('f', 'F'), _keyDef('g', 'G'), _keyDef('h', 'H'),
            _keyDef('j', 'J'), _keyDef('k', 'K'), _keyDef('l', 'L'),
            _keyDef(';', ':'), _keyDef('\'', '"'),
            _keyDef('enter', '↵ Enter', flex: 1.9, specialColor: AppTheme.primaryBlue.withOpacity(0.85)),
          ], isShifted),

          // Row 4: Shift + Bottom Row + Shift
          _buildKeyRow([
            _keyDef('shift', '⇧ Shift', flex: 1.9, isActive: _shift, onTap: () {
              setState(() {
                _shift = !_shift;
                _hid.toggleModifier(HidService.modShift);
              });
            }),
            _keyDef('z', 'Z'), _keyDef('x', 'X'), _keyDef('c', 'C'),
            _keyDef('v', 'V'), _keyDef('b', 'B'), _keyDef('n', 'N'),
            _keyDef('m', 'M'), _keyDef(',', '<'), _keyDef('.', '>'),
            _keyDef('/', '?'),
            _keyDef('shift', '⇧ Shift', flex: 1.9, isActive: _shift, onTap: () {
              setState(() {
                _shift = !_shift;
                _hid.toggleModifier(HidService.modShift);
              });
            }),
          ], isShifted),

          // Row 5: Modifiers + Spacebar + Arrows
          _buildBottomLaptopRow(),
        ],
      ),
    );
  }

  Widget _buildFunctionRow() {
    return SizedBox(
      height: 32,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Row(
          children: [
            _fKey('Esc', 'esc', flex: 1, accent: true),
            const SizedBox(width: 4),
            _fKey('F1', 'f1'), _fKey('F2', 'f2'), _fKey('F3', 'f3'), _fKey('F4', 'f4'),
            const SizedBox(width: 6),
            _fKey('F5', 'f5'), _fKey('F6', 'f6'), _fKey('F7', 'f7'), _fKey('F8', 'f8'),
            const SizedBox(width: 6),
            _fKey('F9', 'f9'), _fKey('F10', 'f10'), _fKey('F11', 'f11'), _fKey('F12', 'f12'),
            const SizedBox(width: 4),
            _fKey('PrtSc', 'printscreen'),
            _fKey('Del', 'delete'),
          ],
        ),
      ),
    );
  }

  Widget _fKey(String label, String key, {int flex = 1, bool accent = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1.5),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () => _onKeyPress(key, display: label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            color: accent ? AppTheme.warningAmber.withOpacity(0.16) : AppTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: accent ? AppTheme.warningAmber.withOpacity(0.5) : AppTheme.outlineVariant),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: accent ? AppTheme.warningAmber : AppTheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _keyDef(String primary, String shifted, {
    double flex = 1.0,
    Color? specialColor,
    bool? isActive,
    VoidCallback? onTap,
  }) {
    return {
      'primary': primary,
      'shifted': shifted,
      'flex': flex,
      'color': specialColor,
      'active': isActive,
      'onTap': onTap,
    };
  }

  Widget _buildKeyRow(List<Map<String, dynamic>> keys, bool isShifted) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: keys.map((k) {
          final primary = k['primary'] as String;
          final shifted = k['shifted'] as String;
          final flex = k['flex'] as double;
          final specialColor = k['color'] as Color?;
          final isActive = k['active'] as bool?;
          final customTap = k['onTap'] as VoidCallback?;

          final displayLabel = isShifted ? shifted : primary;
          final sendKeyChar = isShifted ? shifted : primary;

          return Expanded(
            flex: (flex * 10).toInt(),
            child: _LaptopChicletKey(
              label: displayLabel,
              subLabel: (shifted != primary && !displayLabel.startsWith('⇧') && !displayLabel.startsWith('Caps')) ? (isShifted ? primary : shifted) : null,
              isActive: isActive ?? false,
              backgroundColor: specialColor,
              onTap: customTap ?? () => _onKeyPress(sendKeyChar, display: displayLabel),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomLaptopRow() {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ctrl
          _bottomModifier('Ctrl', _ctrl, () {
            setState(() {
              _ctrl = !_ctrl;
              _hid.toggleModifier(HidService.modCtrl);
            });
          }),
          // Win
          _bottomModifier('Win', _gui, () {
            setState(() {
              _gui = !_gui;
              _hid.toggleModifier(HidService.modGui);
            });
          }),
          // Alt
          _bottomModifier('Alt', _alt, () {
            setState(() {
              _alt = !_alt;
              _hid.toggleModifier(HidService.modAlt);
            });
          }),
          // Spacebar
          Expanded(
            flex: 48,
            child: _LaptopChicletKey(
              label: 'SPACE',
              onTap: () => _onKeyPress('space', display: 'SPACE'),
            ),
          ),
          // AltGr / Alt
          _bottomModifier('Alt', _alt, () {
            setState(() {
              _alt = !_alt;
              _hid.toggleModifier(HidService.modAlt);
            });
          }),
          // Arrow Keys Cluster (Left, Up/Down, Right)
          Expanded(
            flex: 28,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _LaptopChicletKey(
                    label: '◀',
                    onTap: () => _onKeyPress('left', display: '◀'),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: _LaptopChicletKey(
                          label: '▲',
                          onTap: () => _onKeyPress('up', display: '▲'),
                        ),
                      ),
                      Expanded(
                        child: _LaptopChicletKey(
                          label: '▼',
                          onTap: () => _onKeyPress('down', display: '▼'),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _LaptopChicletKey(
                    label: '▶',
                    onTap: () => _onKeyPress('right', display: '▶'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomModifier(String label, bool active, VoidCallback onTap) {
    return Expanded(
      flex: 12,
      child: _LaptopChicletKey(
        label: label,
        isActive: active,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
      ),
    );
  }

  // -------------------------------------------------------------
  // MODE 2: PHONE DEFAULT KEYBOARD (IME / Gboard Bridge)
  // -------------------------------------------------------------
  Widget _buildPhoneKeyboard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Typing Console Area
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.keyboard_outlined, size: 16, color: AppTheme.primaryBlue),
                          SizedBox(width: 6),
                          Text(
                            'PHONE IME BRIDGE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          backgroundColor: AppTheme.surfaceContainer,
                        ),
                        icon: const Icon(Icons.paste_rounded, size: 14),
                        label: const Text('Paste to PC', style: TextStyle(fontSize: 11)),
                        onPressed: _pasteAndSend,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Anything typed using your phone\'s keyboard (Gboard, voice typing, swipe, clipboard) is instantly injected over USB HID into your PC.',
                    style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
                  ),
                  const Divider(height: 20),
                  Expanded(
                    child: TextField(
                      controller: _imeController,
                      focusNode: _imeFocus,
                      maxLines: null,
                      expands: true,
                      autofocus: true,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                        color: AppTheme.onSurface,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Tap here to bring up your phone keyboard and start typing...',
                        hintStyle: TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant),
                        border: InputBorder.none,
                      ),
                      onChanged: _onImeChanged,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Quick Host Shortcuts Bar
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _macroChip('↵ Enter', () => _onKeyPress('enter', display: 'ENTER')),
              _macroChip('⇥ Tab', () => _onKeyPress('tab', display: 'TAB')),
              _macroChip('Esc', () => _onKeyPress('esc', display: 'ESC')),
              _macroChip('Ctrl+C', () {
                _hid.sendKey('c', explicitModifiers: HidService.modCtrl);
                _recordKey('Ctrl+C');
              }),
              _macroChip('Ctrl+V', () {
                _hid.sendKey('v', explicitModifiers: HidService.modCtrl);
                _recordKey('Ctrl+V');
              }),
              _macroChip('Win+R', () {
                _hid.sendKey('r', explicitModifiers: HidService.modGui);
                _recordKey('Win+R');
              }),
              _macroChip('Alt+F4', () {
                _hid.sendKey('f4', explicitModifiers: HidService.modAlt);
                _recordKey('Alt+F4');
              }),
            ],
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _macroChip(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      backgroundColor: AppTheme.surfaceContainerLow,
      side: const BorderSide(color: AppTheme.outlineVariant),
      onPressed: () {
        HapticFeedback.lightImpact();
        onTap();
      },
    );
  }
}

// -------------------------------------------------------------
// LAPTOP CHICLET KEYCAP COMPONENT
// -------------------------------------------------------------
class _LaptopChicletKey extends StatefulWidget {
  const _LaptopChicletKey({
    required this.label,
    this.subLabel,
    required this.onTap,
    this.isActive = false,
    this.backgroundColor,
  });

  final String label;
  final String? subLabel;
  final VoidCallback onTap;
  final bool isActive;
  final Color? backgroundColor;

  @override
  State<_LaptopChicletKey> createState() => _LaptopChicletKeyState();
}

class _LaptopChicletKeyState extends State<_LaptopChicletKey> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isActive
        ? AppTheme.primaryBlue.withOpacity(0.35)
        : (widget.backgroundColor ?? const Color(0xFF23262D));

    final borderColor = widget.isActive
        ? AppTheme.primaryBlue
        : const Color(0xFF343842);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 70),
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: _pressed ? bgColor.withOpacity(0.65) : bgColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: borderColor, width: 0.9),
          boxShadow: _pressed
              ? []
              : const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 1,
                    offset: Offset(0, 1.5),
                  ),
                ],
        ),
        transform: _pressed
            ? (Matrix4.identity()..translate(0.0, 1.5)..scale(0.95))
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.subLabel != null)
                Text(
                  widget.subLabel!,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.onSurfaceVariant.withOpacity(0.6),
                  ),
                ),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: widget.label.length > 2 ? 10.5 : 13,
                  fontWeight: widget.isActive ? FontWeight.w800 : FontWeight.w600,
                  color: widget.isActive ? AppTheme.primaryBlue : AppTheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.clip,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
