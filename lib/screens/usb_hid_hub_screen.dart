import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'usb_keyboard_screen.dart';
import 'usb_touchpad_screen.dart';
import 'payloads_screen.dart';
import 'usb_drive_screen.dart';
import 'device_spoofer_screen.dart';

class UsbHidHubScreen extends StatefulWidget {
  const UsbHidHubScreen({super.key});
  @override
  State<UsbHidHubScreen> createState() => _UsbHidHubScreenState();
}

class _UsbHidHubScreenState extends State<UsbHidHubScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.usb_rounded, color: AppTheme.primaryBlue, size: 18),
          ),
          const SizedBox(width: 10),
          const Text('HID Tool', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        ]),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          children: [
            _buildTelemetry(),
            const SizedBox(height: 14),
            _buildTile(context,
              title: 'USB Keyboard',
              sub: 'Phone becomes a full physical keyboard',
              icon: Icons.keyboard_alt_rounded,
              accent: AppTheme.primaryBlue,
              badge: 'TACTILE',
              dest: const UsbKeyboardScreen()),
            _buildTile(context,
              title: 'USB Touchpad',
              sub: 'Multi-touch trackpad with gestures & clicks',
              icon: Icons.touch_app_rounded,
              accent: AppTheme.successGreen,
              badge: 'MULTI-TOUCH',
              dest: const UsbTouchpadScreen()),
            _buildTile(context,
              title: 'Payloads Studio',
              sub: 'DuckyScript & BadUSB injection engine',
              icon: Icons.terminal_rounded,
              accent: AppTheme.warningAmber,
              badge: 'DUCKYSCRIPT',
              dest: const PayloadsScreen()),
            _buildTile(context,
              title: 'USB Drive',
              sub: 'Mount ISO/IMG as virtual CD-ROM or flash',
              icon: Icons.disc_full_rounded,
              accent: const Color(0xFFC58AF9),
              badge: 'MASS STORAGE',
              dest: const UsbDriveScreen()),
            _buildTile(context,
              title: 'Device Identity Spoofer',
              sub: 'Change USB VID, PID, product & manufacturer',
              icon: Icons.fingerprint_rounded,
              accent: const Color(0xFF78D9EC),
              badge: 'VID/PID',
              dest: const DeviceSpooferScreen()),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetry() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Row(children: [
        AnimatedBuilder(
          animation: _pulseAnim,
          builder: (_, __) => Opacity(
            opacity: _pulseAnim.value,
            child: Container(
              width: 8, height: 8,
              decoration: const BoxDecoration(
                color: AppTheme.successGreen,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('RMX2193 · Kernel 4.14 · arm64-v8a',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.onSurface)),
            const SizedBox(height: 2),
            Text('Magisk Root · CONFIG_USB_F_HID=y · /dev/hidg0',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 10.5, color: AppTheme.onSurfaceVariant)),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: AppTheme.successGreen.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text('READY',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
              letterSpacing: 0.5, color: AppTheme.successGreen)),
        ),
      ]),
    );
  }

  Widget _buildTile(BuildContext context, {
    required String title, required String sub, required IconData icon,
    required Color accent, required String badge, required Widget dest,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(context, MaterialPageRoute(builder: (_) => dest));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(badge,
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold,
                          letterSpacing: 0.4, color: accent)),
                    ),
                  ]),
                  const SizedBox(height: 2),
                  Text(sub,
                    style: const TextStyle(fontSize: 11.5, color: AppTheme.onSurfaceVariant)),
                ],
              )),
              const Icon(Icons.chevron_right_rounded, size: 18, color: AppTheme.onSurfaceVariant),
            ]),
          ),
        ),
      ),
    );
  }
}
