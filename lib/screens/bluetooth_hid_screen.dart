import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'usb_keyboard_screen.dart';
import 'usb_touchpad_screen.dart';

class BluetoothHidScreen extends StatefulWidget {
  const BluetoothHidScreen({super.key});

  @override
  State<BluetoothHidScreen> createState() => _BluetoothHidScreenState();
}

class _BluetoothHidScreenState extends State<BluetoothHidScreen> {
  bool _isDiscovering = false;
  String? _connectedDevice;

  final List<Map<String, dynamic>> _devices = [
    {"name": "MacBook Pro (Gourav)", "type": "Laptop", "paired": true, "rssi": -55},
    {"name": "DESKTOP-WIN11-PRO", "type": "PC", "paired": false, "rssi": -68},
    {"name": "Living Room TV", "type": "TV", "paired": false, "rssi": -82},
  ];

  void _scan() {
    HapticFeedback.selectionClick();
    setState(() => _isDiscovering = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isDiscovering = false);
    });
  }

  void _connect(String name) {
    HapticFeedback.mediumImpact();
    setState(() => _connectedDevice = (_connectedDevice == name ? null : name));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bluetooth HID"),
        actions: [
          IconButton(
            tooltip: "Scan for Devices",
            icon: _isDiscovering
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryBlue),
                  )
                : const Icon(Icons.refresh_rounded),
            onPressed: _isDiscovering ? null : _scan,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Status Card
            _buildBtStatusCard(),

            const SizedBox(height: 16),

            // Discovered Hosts List
            const Text(
              "Available Hosts & Paired Devices",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            ..._devices.map((dev) => _buildDeviceTile(dev)),

            const SizedBox(height: 20),

            // Wireless Controls
            if (_connectedDevice != null) ...[
              const Text(
                "Wireless Controllers",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: const BorderSide(color: AppTheme.primaryBlue),
                      ),
                      icon: const Icon(Icons.keyboard_outlined, color: AppTheme.primaryBlue),
                      label: const Text("AIR KEYBOARD", style: TextStyle(color: AppTheme.primaryBlue)),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const UsbKeyboardScreen()));
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: const BorderSide(color: AppTheme.successGreen),
                      ),
                      icon: const Icon(Icons.touch_app_outlined, color: AppTheme.successGreen),
                      label: const Text("AIR MOUSE", style: TextStyle(color: AppTheme.successGreen)),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const UsbTouchpadScreen()));
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBtStatusCard() {
    final connected = _connectedDevice != null;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: connected ? AppTheme.primaryBlue : AppTheme.outlineVariant,
          width: connected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: connected ? AppTheme.primaryContainer.withOpacity(0.2) : AppTheme.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bluetooth_connected_rounded,
              color: connected ? AppTheme.primaryBlue : AppTheme.onSurfaceVariant,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  connected ? "CONNECTED: $_connectedDevice" : "BLUETOOTH READY",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: connected ? AppTheme.primaryBlue : AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  connected ? "Emulating Bluetooth HID Keyboard & Trackpad" : "Android 11+ AOSP BluetoothHidDevice Active",
                  style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceTile(Map<String, dynamic> dev) {
    final isConn = _connectedDevice == dev["name"];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isConn ? AppTheme.primaryBlue : AppTheme.outlineVariant),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        leading: Icon(
          dev["type"] == "Laptop" ? Icons.laptop_mac : (dev["type"] == "PC" ? Icons.desktop_windows : Icons.tv),
          color: isConn ? AppTheme.primaryBlue : AppTheme.onSurfaceVariant,
        ),
        title: Text(dev["name"], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5)),
        subtitle: Text("${dev['type']} • RSSI: ${dev['rssi']} dBm", style: const TextStyle(fontSize: 12)),
        trailing: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: isConn ? AppTheme.alertContainer : AppTheme.surfaceContainerHighest,
            foregroundColor: isConn ? Colors.white : AppTheme.onSurface,
          ),
          onPressed: () => _connect(dev["name"]),
          child: Text(isConn ? "Disconnect" : "Connect"),
        ),
      ),
    );
  }
}
