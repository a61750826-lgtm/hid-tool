import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class UsbDriveScreen extends StatefulWidget {
  const UsbDriveScreen({super.key});

  @override
  State<UsbDriveScreen> createState() => _UsbDriveScreenState();
}

class _UsbDriveScreenState extends State<UsbDriveScreen> {
  bool _isMounted = false;
  bool _readOnly = true;
  bool _emulateCdrom = true;
  String _selectedImage = "/sdcard/Downloads/recovery.iso";
  String _driveLabel = "VIRTUAL_USB";

  final List<String> _sampleImages = [
    "/sdcard/Downloads/recovery.iso",
    "/sdcard/ISOs/archlinux-latest.iso",
    "/sdcard/ISOs/hirens-boot-cd.iso",
    "/sdcard/custom_payload_drive.img",
  ];

  void _toggleMount() {
    HapticFeedback.mediumImpact();
    setState(() => _isMounted = !_isMounted);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("USB Drive Mounter"),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Status Card
            _buildStatusCard(),

            const SizedBox(height: 16),

            // Image Selection Card
            _buildImageSelectionCard(),

            const SizedBox(height: 16),

            // Drive Configuration Card
            _buildConfigCard(),

            const SizedBox(height: 24),

            // Mount / Eject Action Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isMounted ? AppTheme.alertContainer : AppTheme.primaryBlue,
                foregroundColor: _isMounted ? Colors.white : const Color(0xFF003063),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              icon: Icon(_isMounted ? Icons.eject_rounded : Icons.usb_rounded),
              label: Text(
                _isMounted ? "EJECT USB DRIVE" : "MOUNT AS USB DRIVE",
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              onPressed: _toggleMount,
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
          color: _isMounted ? AppTheme.successGreen : AppTheme.outlineVariant,
          width: _isMounted ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _isMounted ? AppTheme.successContainer.withOpacity(0.2) : AppTheme.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isMounted ? Icons.disc_full_rounded : Icons.disc_full_outlined,
              size: 28,
              color: _isMounted ? AppTheme.successGreen : AppTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isMounted ? "DRIVE ACTIVE & MOUNTED" : "DRIVE OFFLINE",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: _isMounted ? AppTheme.successGreen : AppTheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isMounted ? "Host PC detects as ${_emulateCdrom ? 'Virtual CD-ROM' : 'USB Flash Drive'}" : "Select an image and tap Mount",
                  style: const TextStyle(fontSize: 12.5, color: AppTheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSelectionCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Selected ISO / Disk Image",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.outlineVariant),
            ),
            child: Row(
              children: [
                const Icon(Icons.insert_drive_file_outlined, size: 20, color: AppTheme.primaryBlue),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _selectedImage,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: _sampleImages.map((path) {
              final name = path.split('/').last;
              final isChosen = _selectedImage == path;
              return ChoiceChip(
                label: Text(name),
                selected: isChosen,
                selectedColor: AppTheme.primaryBlue.withOpacity(0.2),
                labelStyle: TextStyle(
                  fontSize: 11.5,
                  color: isChosen ? AppTheme.primaryBlue : AppTheme.onSurfaceVariant,
                  fontWeight: isChosen ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: isChosen ? AppTheme.primaryBlue : AppTheme.outlineVariant),
                ),
                onSelected: (_) => setState(() => _selectedImage = path),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Gadget Options",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("Read-Only Mode"),
            subtitle: const Text("Prevents host from writing or modifying ISO", style: TextStyle(fontSize: 12)),
            value: _readOnly,
            activeColor: AppTheme.primaryBlue,
            onChanged: (v) => setState(() => _readOnly = v),
          ),
          const Divider(color: AppTheme.outlineVariant, height: 1),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("CD-ROM Emulation"),
            subtitle: const Text("Emulates hardware CD-ROM instead of removable flash", style: TextStyle(fontSize: 12)),
            value: _emulateCdrom,
            activeColor: AppTheme.primaryBlue,
            onChanged: (v) => setState(() => _emulateCdrom = v),
          ),
        ],
      ),
    );
  }
}
