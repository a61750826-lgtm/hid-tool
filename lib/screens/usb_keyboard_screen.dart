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
  final HidService _hid = HidService();
  String _lastPressed = "READY";
  final List<String> _history = [];
  bool _capsLock = false;
  bool _showFKeys = false;

  void _onKeyPress(String key) {
    setState(() {
      _lastPressed = key;
      _history.add(key);
      if (_history.length > 20) _history.removeAt(0);
    });
    _hid.sendKey(key);
  }

  void _toggleModifier(int mask, String label) {
    setState(() {
      _hid.toggleModifier(mask);
      _lastPressed = "$label: ${_hid.isModifierActive(mask) ? 'ON' : 'OFF'}";
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: const Text("USB Keyboard"),
        actions: [
          IconButton(
            tooltip: "Toggle F-Keys Bar",
            icon: Icon(_showFKeys ? Icons.keyboard_hide_outlined : Icons.keyboard_outlined, color: AppTheme.primaryBlue),
            onPressed: () => setState(() => _showFKeys = !_showFKeys),
          ),
          IconButton(
            tooltip: "Clear History",
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () => setState(() {
              _history.clear();
              _lastPressed = "CLEARED";
            }),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Telemetry & Keystroke Monitor Bar
            _buildKeystrokeMonitor(),

            // Optional F-Keys Strip
            if (_showFKeys) _buildFKeysRow(),

            // Modifier Control Bar
            _buildModifierBar(),

            const Spacer(),

            // Responsive Main Keyboard Matrix
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isLandscape ? 32 : 6,
                vertical: 8,
              ),
              child: _buildMainKeyMatrix(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeystrokeMonitor() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _lastPressed,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _history.isEmpty ? "Tap any key to inject USB HID scancodes..." : _history.join(" • "),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModifierBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildModifierChip("CTRL", HidService.modCtrl),
            _buildModifierChip("ALT", HidService.modAlt),
            _buildModifierChip("WIN / GUI", HidService.modGui),
            _buildModifierChip("SHIFT", HidService.modShift),
            _buildActionChip("ESC", () => _onKeyPress("esc")),
            _buildActionChip("TAB", () => _onKeyPress("tab")),
            _buildActionChip("CAPS", () {
              setState(() => _capsLock = !_capsLock);
              _onKeyPress("capslock");
            }, active: _capsLock),
          ],
        ),
      ),
    );
  }

  Widget _buildModifierChip(String label, int mask) {
    final active = _hid.isModifierActive(mask);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: active,
        label: Text(label),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: active ? AppTheme.surface : AppTheme.onSurface,
        ),
        selectedColor: AppTheme.primaryBlue,
        backgroundColor: AppTheme.surfaceContainerHigh,
        checkmarkColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: active ? AppTheme.primaryBlue : AppTheme.outlineVariant),
        ),
        onSelected: (_) => _toggleModifier(mask, label),
      ),
    );
  }

  Widget _buildActionChip(String label, VoidCallback onTap, {bool active = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: active ? AppTheme.surface : AppTheme.onSurfaceVariant,
        ),
        backgroundColor: active ? AppTheme.warningAmber : AppTheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppTheme.outlineVariant),
        ),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildFKeysRow() {
    return Container(
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 12,
        itemBuilder: (context, i) {
          final fKey = "F${i + 1}";
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: SizedBox(
              width: 52,
              child: _buildKeycap(fKey, fKey.toLowerCase()),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainKeyMatrix() {
    final rows = [
      ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-'],
      ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
      ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'],
      ['z', 'x', 'c', 'v', 'b', 'n', 'm', '.', '/'],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var row in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var key in row)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.5),
                      child: _buildKeycap(
                        _capsLock ? key.toUpperCase() : key,
                        key,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        // Bottom Row: Spacebar, Enter, Backspace, Arrow keys
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildKeycap("⌫ Del", "backspace", color: AppTheme.surfaceContainerHighest),
              ),
              const SizedBox(width: 4),
              Expanded(
                flex: 4,
                child: _buildKeycap("SPACE", "space"),
              ),
              const SizedBox(width: 4),
              Expanded(
                flex: 2,
                child: _buildKeycap("↵ Enter", "enter", color: AppTheme.primaryContainer, textColor: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKeycap(String label, String value, {Color? color, Color? textColor}) {
    return Material(
      color: color ?? AppTheme.surfaceContainer,
      elevation: 1,
      shadowColor: Colors.black45,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _onKeyPress(value),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.6), width: 1),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: label.length > 2 ? 12 : 17,
              fontWeight: FontWeight.w600,
              color: textColor ?? AppTheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
