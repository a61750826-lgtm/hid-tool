import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/usb_hid_hub_screen.dart';
import 'screens/bluetooth_hid_screen.dart';
import 'screens/boot_manager_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppTheme.surface,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const HidToolApp());
}

class HidToolApp extends StatelessWidget {
  const HidToolApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HID Tool',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const RootShell(),
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});
  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  static const _pages = [
    UsbHidHubScreen(),
    BluetoothHidScreen(),
    BootManagerScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          HapticFeedback.selectionClick();
          setState(() => _index = i);
        },
        backgroundColor: AppTheme.surfaceContainerLow,
        indicatorColor: AppTheme.primaryBlue.withOpacity(0.18),
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.usb_outlined),
            selectedIcon: Icon(Icons.usb_rounded, color: AppTheme.primaryBlue),
            label: 'USB HID',
          ),
          NavigationDestination(
            icon: Icon(Icons.bluetooth_outlined),
            selectedIcon: Icon(Icons.bluetooth_rounded, color: AppTheme.successGreen),
            label: 'Bluetooth',
          ),
          NavigationDestination(
            icon: Icon(Icons.power_settings_new_outlined),
            selectedIcon: Icon(Icons.power_settings_new_rounded, color: AppTheme.warningAmber),
            label: 'Boot',
          ),
        ],
      ),
    );
  }
}
