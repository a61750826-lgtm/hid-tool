import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class DeviceSpooferScreen extends StatefulWidget {
  const DeviceSpooferScreen({super.key});

  @override
  State<DeviceSpooferScreen> createState() => _DeviceSpooferScreenState();
}

class _DeviceSpooferScreenState extends State<DeviceSpooferScreen> {
  final TextEditingController _vidController = TextEditingController(text: "0x413c");
  final TextEditingController _pidController = TextEditingController(text: "0x2003");
  final TextEditingController _manufacturerController = TextEditingController(text: "Dell Inc.");
  final TextEditingController _productController = TextEditingController(text: "QuietKey USB Keyboard");

  final List<Map<String, String>> _presets = [
    {
      "name": "Dell QuietKey",
      "vid": "0x413c",
      "pid": "0x2003",
      "manufacturer": "Dell Inc.",
      "product": "QuietKey USB Keyboard",
    },
    {
      "name": "Apple Magic Keyboard",
      "vid": "0x05ac",
      "pid": "0x0267",
      "manufacturer": "Apple Inc.",
      "product": "Magic Keyboard with Numeric Keypad",
    },
    {
      "name": "Logitech G Pro",
      "vid": "0x046d",
      "pid": "0xc33c",
      "manufacturer": "Logitech",
      "product": "G Pro Gaming Keyboard",
    },
    {
      "name": "Lenovo ThinkPad",
      "vid": "0x17ef",
      "pid": "0x6009",
      "manufacturer": "Lenovo",
      "product": "ThinkPad Compact USB Keyboard",
    },
  ];

  void _applyPreset(Map<String, String> p) {
    HapticFeedback.selectionClick();
    setState(() {
      _vidController.text = p["vid"]!;
      _pidController.text = p["pid"]!;
      _manufacturerController.text = p["manufacturer"]!;
      _productController.text = p["product"]!;
    });
  }

  void _saveIdentity() {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Hardware Identity Applied: ${_productController.text}"),
        backgroundColor: AppTheme.successContainer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Device Identity Spoofer"),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Presets Header
            const Text(
              "Hardware Presets",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Presets List
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _presets.map((p) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ActionChip(
                      avatar: const Icon(Icons.devices, size: 16, color: AppTheme.primaryBlue),
                      label: Text(p["name"]!),
                      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      backgroundColor: AppTheme.surfaceContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppTheme.outlineVariant),
                      ),
                      onPressed: () => _applyPreset(p),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Form Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainer,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Vendor ID (VID)", style: TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _vidController,
                    decoration: const InputDecoration(hintText: "e.g. 0x413c"),
                  ),
                  const SizedBox(height: 16),
                  const Text("Product ID (PID)", style: TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _pidController,
                    decoration: const InputDecoration(hintText: "e.g. 0x2003"),
                  ),
                  const SizedBox(height: 16),
                  const Text("Manufacturer Name", style: TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _manufacturerController,
                    decoration: const InputDecoration(hintText: "e.g. Dell Inc."),
                  ),
                  const SizedBox(height: 16),
                  const Text("Product String", style: TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _productController,
                    decoration: const InputDecoration(hintText: "e.g. QuietKey USB Keyboard"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: const Color(0xFF003063),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text("APPLY TO USB GADGET", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              onPressed: _saveIdentity,
            ),
          ],
        ),
      ),
    );
  }
}
