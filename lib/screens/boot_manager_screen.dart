import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class BootManagerScreen extends StatefulWidget {
  const BootManagerScreen({super.key});

  @override
  State<BootManagerScreen> createState() => _BootManagerScreenState();
}

class _BootManagerScreenState extends State<BootManagerScreen> {
  bool _isPersistentEnabled = true;
  bool _runPayloadOnBoot = false;

  final String _scriptPreview = """#!/system/bin/sh
# Magisk Boot Service for USB HID Gadget
# Target: Realme Narzo 20 (RMX2193 / Helio G85)
# Kernel: 4.14.186+ arm64-v8a

wait_until_boot_completed() {
  while [ "\$(getprop sys.boot_completed)" != "1" ]; do
    sleep 1
  done
}

wait_until_boot_completed

# Unbind UDC temporarily
setprop sys.usb.config none
sleep 1

# Link HID function into active config
if [ -d /config/usb_gadget/g1 ]; then
  ln -s /config/usb_gadget/g1/functions/hid.gs0 /config/usb_gadget/g1/configs/b.1/f2 2>/dev/null
  setprop sys.usb.config adb,hid
  mknod /dev/hidg0 c 489 0 2>/dev/null
  chmod 666 /dev/hidg0
fi
""";

  void _togglePersistence(bool val) {
    HapticFeedback.mediumImpact();
    setState(() => _isPersistentEnabled = val);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(val ? "Magisk Boot Script Activated in service.d" : "Magisk Boot Script Deactivated"),
        backgroundColor: val ? AppTheme.successContainer : AppTheme.alertContainer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Boot & Autorun"),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Status Card
            _buildStatusCard(),

            const SizedBox(height: 16),

            // Persistent Toggles Card
            _buildTogglesCard(),

            const SizedBox(height: 16),

            // Script Preview Card
            _buildScriptPreviewCard(),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: const Color(0xFF003063),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              icon: const Icon(Icons.flash_on_rounded),
              label: const Text("TEST RUN BOOT SCRIPT NOW", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              onPressed: () {
                HapticFeedback.heavyImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Executed /data/adb/service.d/hid_enabler.sh"),
                    backgroundColor: AppTheme.successContainer,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _isPersistentEnabled ? AppTheme.successGreen : AppTheme.outlineVariant,
          width: _isPersistentEnabled ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isPersistentEnabled ? AppTheme.successContainer.withOpacity(0.2) : AppTheme.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.power_settings_new_rounded,
              size: 28,
              color: _isPersistentEnabled ? AppTheme.successGreen : AppTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isPersistentEnabled ? "BOOT PERSISTENCE ACTIVE" : "BOOT PERSISTENCE DISABLED",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _isPersistentEnabled ? AppTheme.successGreen : AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "/data/adb/service.d/hid_enabler.sh will execute on system restart",
                  style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTogglesCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("Enable HID at Boot"),
            subtitle: const Text("Pre-creates /dev/hidg0 before any app opens", style: TextStyle(fontSize: 12)),
            value: _isPersistentEnabled,
            activeColor: AppTheme.primaryBlue,
            onChanged: _togglePersistence,
          ),
          const Divider(color: AppTheme.outlineVariant, height: 1),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("Autorun Default Payload"),
            subtitle: const Text("Injects selected DuckyScript automatically when phone powers on", style: TextStyle(fontSize: 12)),
            value: _runPayloadOnBoot,
            activeColor: AppTheme.warningAmber,
            onChanged: (v) => setState(() => _runPayloadOnBoot = v),
          ),
        ],
      ),
    );
  }

  Widget _buildScriptPreviewCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Magisk Boot Script Content",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                "chmod 755",
                style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: AppTheme.primaryBlue),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDim,
              borderRadius: BorderRadius.circular(14),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                _scriptPreview,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11.5,
                  height: 1.4,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
