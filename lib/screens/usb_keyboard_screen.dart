import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/hid_service.dart';
import '../theme/app_theme.dart';

class UsbKeyboardScreen extends StatefulWidget {
  const UsbKeyboardScreen({super.key});
  @override
  State<UsbKeyboardScreen> createState() => _UsbKeyboardScreenState();
}

class _UsbKeyboardScreenState extends State<UsbKeyboardScreen> {
  final _hid = HidService();
  final _log = <String>[];
  bool _ctrl = false, _alt = false, _shift = false, _gui = false, _caps = false;

  void _sendKey(String key, String displayLabel) {
    HapticFeedback.lightImpact();
    _hid.sendKey(key);
    setState(() {
      if (_log.length >= 6) _log.removeAt(0);
      _log.add(_buildModStr() + displayLabel);
    });
  }

  String _buildModStr() {
    final m = <String>[];
    if (_ctrl) m.add('CTRL');
    if (_alt) m.add('ALT');
    if (_shift) m.add('SHIFT');
    if (_gui) m.add('WIN');
    return m.isEmpty ? '' : '${m.join('+')}+';
  }

  static const _rows = [
    ['1','2','3','4','5','6','7','8','9','0','-','='],
    ['q','w','e','r','t','y','u','i','o','p','[',']'],
    ['a','s','d','f','g','h','j','k','l',';','\''],
    ['z','x','c','v','b','n','m',',','.','/'],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('USB Keyboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded, size: 20),
            tooltip: 'Clear log',
            onPressed: () => setState(() => _log.clear()),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(children: [
          // Status strip
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _log.isEmpty
                    ? '⌨ Tap any key to inject USB HID scancodes...'
                    : _log.last,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11.5,
                  color: AppTheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          // Modifier chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(children: [
              _modChip('CTRL', _ctrl, AppTheme.primaryBlue, () {
                _hid.toggleModifier(HidService.modCtrl);
                setState(() => _ctrl = !_ctrl);
              }),
              const SizedBox(width: 6),
              _modChip('ALT', _alt, AppTheme.primaryBlue, () {
                _hid.toggleModifier(HidService.modAlt);
                setState(() => _alt = !_alt);
              }),
              const SizedBox(width: 6),
              _modChip('SHIFT', _shift, AppTheme.primaryBlue, () {
                _hid.toggleModifier(HidService.modShift);
                setState(() => _shift = !_shift);
              }),
              const SizedBox(width: 6),
              _modChip('WIN', _gui, AppTheme.primaryBlue, () {
                _hid.toggleModifier(HidService.modGui);
                setState(() => _gui = !_gui);
              }),
              const SizedBox(width: 10),
              _actionChip('ESC', 'esc'),
              const SizedBox(width: 6),
              _actionChip('TAB', 'tab'),
              const SizedBox(width: 6),
              _modChip('CAPS', _caps, AppTheme.warningAmber, () {
                setState(() {
                  _caps = !_caps;
                  _sendKey('capslock', 'CAPS');
                });
              }),
            ]),
          ),
          // Main keyboard matrix filling remaining space
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 4),
              child: Column(children: [
                ..._rows.map((r) => _buildRow(r)),
                _buildBottomRow(),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildRow(List<String> keys) {
    return Expanded(
      child: Row(
        children: keys.map((k) => _Key(
          label: k,
          onTap: () => _sendKey(k, k.toUpperCase()),
        )).toList(),
      ),
    );
  }

  Widget _buildBottomRow() {
    return Expanded(
      child: Row(children: [
        _Key(
          label: '⌫',
          flex: 2,
          color: AppTheme.surfaceContainer,
          onTap: () => _sendKey('backspace', 'BKSP'),
        ),
        _Key(
          label: 'SPACE',
          flex: 5,
          color: AppTheme.surfaceContainer,
          onTap: () => _sendKey('space', 'SPACE'),
        ),
        _Key(
          label: '↵',
          flex: 2,
          color: AppTheme.primaryBlue.withOpacity(0.85),
          onTap: () => _sendKey('enter', 'ENTER'),
        ),
      ]),
    );
  }

  Widget _modChip(String label, bool active, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.22) : AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? color : AppTheme.outlineVariant),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: active ? color : AppTheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _actionChip(String label, String key) {
    return GestureDetector(
      onTap: () => _sendKey(key, label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.outlineVariant),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _Key extends StatefulWidget {
  const _Key({
    required this.label,
    required this.onTap,
    this.flex = 1,
    this.color,
  });
  final String label;
  final VoidCallback onTap;
  final int flex;
  final Color? color;
  @override
  State<_Key> createState() => _KeyState();
}

class _KeyState extends State<_Key> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: widget.flex,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: _pressed
                ? (widget.color ?? AppTheme.surfaceContainer).withOpacity(0.6)
                : (widget.color ?? AppTheme.surfaceContainer),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
          ),
          transform: _pressed
              ? (Matrix4.identity()..scale(0.93))
              : Matrix4.identity(),
          transformAlignment: Alignment.center,
          child: Center(
            child: Text(
              widget.label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurface,
              ),
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
  }
}
