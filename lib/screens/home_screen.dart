import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'usb_hid_hub_screen.dart';
import 'bluetooth_hid_screen.dart';
import 'boot_manager_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.hub_rounded, color: AppTheme.primaryBlue, size: 22),
            ),
            const SizedBox(width: 12),
            const Text("HID Tool"),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          children: [
            // Live Device Hardware Telemetry Banner
            _buildTelemetryBanner(),

            const SizedBox(height: 24),

            const Text(
              "INTERFACE SELECTOR",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: AppTheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 14),

            // Option 1: USB HID
            _buildHeroCard(
              context,
              title: "USB HID",
              badgeText: "HIGH SPEED CABLE",
              badgeColor: AppTheme.primaryBlue,
              description: "Physical USB peripheral emulation: Keyboard, Precision Touchpad, DuckyScript Payloads, USB Drive, and VID/PID spoofing.",
              icon: Icons.usb_rounded,
              accentColor: AppTheme.primaryBlue,
              stats: "ConfigFS • 480 Mbps • Zero Host Lag",
              destination: const UsbHidHubScreen(),
            ),

            const SizedBox(height: 16),

            // Option 2: Bluetooth HID
            _buildHeroCard(
              context,
              title: "Bluetooth HID",
              badgeText: "WIRELESS AIR",
              badgeColor: AppTheme.successGreen,
              description: "Wireless host pairing via Android 11+ AOSP Bluetooth HID Device stack. Control PCs, TVs, and laptops without cables.",
              icon: Icons.bluetooth_searching_rounded,
              accentColor: AppTheme.successGreen,
              stats: "AOSP HID Profile • No Dongle Needed",
              destination: const BluetoothHidScreen(),
            ),

            const SizedBox(height: 16),

            // Option 3: Boot & Autorun
            _buildHeroCard(
              context,
              title: "Boot & Persistence",
              badgeText: "MAGISK SYSTEM",
              badgeColor: AppTheme.warningAmber,
              description: "Configure persistent kernel gadget binding on device boot. Pre-creates /dev/hidg0 before any application launches.",
              icon: Icons.power_settings_new_rounded,
              accentColor: AppTheme.warningAmber,
              stats: "service.d Script • Reboot Resistant",
              destination: const BootManagerScreen(),
            ),

            const SizedBox(height: 28),

            // Bottom System Architecture Badge
            _buildArchitectureFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: AppTheme.successGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "TARGET HARDWARE READY",
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: AppTheme.successGreen,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "arm64-v8a",
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.phone_android_rounded, size: 18, color: AppTheme.onSurfaceVariant),
              SizedBox(width: 8),
              Text(
                "Realme Narzo 20 (RMX2193) • Kernel 4.14",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Row(
            children: [
              Icon(Icons.verified_user_outlined, size: 18, color: AppTheme.successGreen),
              SizedBox(width: 8),
              Text(
                "Magisk Root Active • CONFIG_USB_F_HID=y",
                style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(
    BuildContext context, {
    required String title,
    required String badgeText,
    required Color badgeColor,
    required String description,
    required IconData icon,
    required Color accentColor,
    required String stats,
    required Widget destination,
  }) {
    return Material(
      color: AppTheme.surfaceContainer,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(context, MaterialPageRoute(builder: (_) => destination));
        },
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.outlineVariant, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: accentColor, size: 28),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: badgeColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                  color: AppTheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: AppTheme.outlineVariant, height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    stats,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11.5,
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded, size: 18, color: AppTheme.onSurfaceVariant),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArchitectureFooter() {
    return Center(
      child: Text(
        "Strict arm64-v8a • Google Material 3 Expressive System",
        style: TextStyle(
          fontSize: 11.5,
          color: AppTheme.onSurfaceVariant.withOpacity(0.5),
        ),
      ),
    );
  }
}
