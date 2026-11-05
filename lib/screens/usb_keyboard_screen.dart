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
  String _lastKey = '';

  void _sendKey(String label, int scancode) {
    HapticFeedback.lightImpact();
    int mod = 0;
    if (_ctrl) mod |= HidService.kCtrl;
    if (_alt) mod |= HidService.kAlt;
    if (_shift) mod |= HidService.kShift;
    if (_gui) mod |= HidService.kGui;
    _hid.sendKey(scancode: scancode, modifier: mod);
    setState(() {
      _lastKey = label;
      if (_log.length >= 6) _log.removeAt(0);
      _log.add(_buildModStr() + label);
    });
  }

  String _buildModStr() {
    final m = <String>[];
    if (_ctrl) m.add('C');
    if (_alt) m.add('A');
    if (_shift) m.add('S');
    if (_gui) m.add('G');
    return m.isEmpty ? '' : '${m.join('+')}+';
  }

  static const _rows = [
    ['1','2','3','4','5','6','7','8','9','0','-','='],
    ['q','w','e','r','t','y','u','i','o','p','[',']'],
    ['a','s','d','f','g','h','j','k','l',';',"'"],
    ['z','x','c','v','b','n','m',',','.','/',' \\'],
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
                _log.isEmpty ? '⌨  Tap any key to inject USB HID scancodes...'
                  : _log.last,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11.5,
                  color: AppTheme.onSurfaceVariant),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          // Modifier chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(children: [
              _modChip('CTRL', _ctrl, AppTheme.primaryBlue,
                () => setState(() => _ctrl = !_ctrl)),
              const SizedBox(width: 6),
              _modChip('ALT', _alt, AppTheme.primaryBlue,
                () => setState(() => _alt = !_alt)),
              const SizedBox(width: 6),
              _modChip('SHIFT', _shift, AppTheme.primaryBlue,
                () => setState(() => _shift = !_shift)),
              const SizedBox(width: 6),
              _modChip('WIN', _gui, AppTheme.primaryBlue,
                () => setState(() => _gui = !_gui)),
              const SizedBox(width: 10),
              _actionChip('ESC', 0x29),
              const SizedBox(width: 6),
              _actionChip('TAB', 0x2B),
              const SizedBox(width: 6),
              _modChip('CAPS', _caps, AppTheme.warningAmber,
                () => setState(() { _caps = !_caps; _sendKey('CAPS', 0x39); })),
            ]),
          ),
          // Main keyboard — fills remaining height
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 4),
              child: Column(children: [
                ..._rows.asMap().entries.map((e) => _buildRow(e.value)),
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
          onTap: () => _sendKey(k, HidService.scancodeMap[k.toLowerCase()] ?? 0),
        )).toList(),
      ),
    );
  }

  Widget _buildBottomRow() {
    return Expanded(
      child: Row(children: [
        _Key(label: '⌫', flex: 2, color: AppTheme.surfaceContainer,
          onTap: () => _sendKey('BKSP', 0x2A)),
        _Key(label: 'SPACE', flex: 5, color: AppTheme.surfaceContainer,
          onTap: () => _sendKey('SPACE', 0x2C)),
        _Key(label: '↵', flex: 2, color: AppTheme.primaryBlue.withOpacity(0.85),
          onTap: () => _sendKey('ENTER', 0x28)),
      ]),
    );
  }

  Widget _modChip(String label, bool active, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); onTap(); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.22) : AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? color : AppTheme.outlineVariant),
        ),
        child: Text(label, style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w700,
          color: active ? color : AppTheme.onSurfaceVariant,
        )),
      ),
    );
  }

  Widget _actionChip(String label, int code) {
    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); _sendKey(label, code); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.outlineVariant),
        ),
        child: Text(label, style: const TextStyle(
          fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.onSurfaceVariant)),
      ),
    );
  }
}

class _Key extends StatefulWidget {
  const _Key({required this.label, required this.onTap, this.flex = 1, this.color});
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
        onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
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
            child: Text(widget.label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: AppTheme.onSurface),
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
  }
}
