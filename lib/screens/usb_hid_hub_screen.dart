import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'usb_keyboard_screen.dart';
import 'usb_touchpad_screen.dart';
import 'payloads_screen.dart';
import 'usb_drive_screen.dart';
import 'device_spoofer_screen.dart';

class UsbHidHubScreen extends StatelessWidget {
  const UsbHidHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("USB HID Interface"),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            // Status Header
            _buildUsbStatusBanner(),

            const SizedBox(height: 16),

            // Feature 1: USB Keyboard
            _buildFeatureTile(
              context,
              title: "USB Keyboard",
              subtitle: "Phone screen turns into full tactile physical keyboard with modifiers",
              icon: Icons.keyboard_alt_rounded,
              accentColor: AppTheme.primaryBlue,
              badge: "TACTILE",
              destination: const UsbKeyboardScreen(),
            ),

            const SizedBox(height: 12),

            // Feature 2: USB Touchpad
            _buildFeatureTile(
              context,
              title: "USB Touchpad",
              subtitle: "Frosted precision trackpad with gestures, left/right clicks & scroll",
              icon: Icons.touch_app_rounded,
              accentColor: AppTheme.successGreen,
              badge: "MULTI-TOUCH",
              destination: const UsbTouchpadScreen(),
            ),

            const SizedBox(height: 12),

            // Feature 3: Payloads Studio
            _buildFeatureTile(
              context,
              title: "Payloads Studio",
              subtitle: "BadUSB & DuckyScript injection engine with live execution logs",
              icon: Icons.terminal_rounded,
              accentColor: AppTheme.warningAmber,
              badge: "DUCKYSCRIPT",
              destination: const PayloadsScreen(),
            ),

            const SizedBox(height: 12),

            // Feature 4: USB Drive
            _buildFeatureTile(
              context,
              title: "USB Drive",
              subtitle: "Mount ISO/IMG disk images as virtual CD-ROM or USB flash drive",
              icon: Icons.disc_full_rounded,
              accentColor: const Color(0xFFC58AF9),
              badge: "MASS STORAGE",
              destination: const UsbDriveScreen(),
            ),

            const SizedBox(height: 12),

            // Feature 5: Device Identity Spoofer
            _buildFeatureTile(
              context,
              title: "Device Identity Spoofer",
              subtitle: "Spoof USB VID, PID, Product Name, and Manufacturer strings",
              icon: Icons.fingerprint_rounded,
              accentColor: const Color(0xFF78D9EC),
              badge: "VID / PID",
              destination: const DeviceSpooferScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsbStatusBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.usb, color: AppTheme.successGreen, size: 24),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "USB Device Controller Active",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.onSurface),
                ),
                SizedBox(height: 2),
                Text(
                  "High-Speed 480 Mbps • ConfigFS /dev/hidg0",
                  style: TextStyle(fontFamily: 'monospace', fontSize: 11.5, color: AppTheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required String badge,
    required Widget destination,
  }) {
    return Material(
      color: AppTheme.surfaceContainer,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(context, MaterialPageRoute(builder: (_) => destination));
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppTheme.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12.5, color: AppTheme.onSurfaceVariant, height: 1.3),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppTheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
