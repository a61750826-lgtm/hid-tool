import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/hid_service.dart';
import '../theme/app_theme.dart';

class UsbTouchpadScreen extends StatefulWidget {
  const UsbTouchpadScreen({super.key});

  @override
  State<UsbTouchpadScreen> createState() => _UsbTouchpadScreenState();
}

class _UsbTouchpadScreenState extends State<UsbTouchpadScreen> {
  final HidService _hid = HidService();
  double _sensitivity = 1.0;
  double _lastX = 0;
  double _lastY = 0;
  String _gestureStatus = "IDLE";
  bool _leftPressed = false;
  bool _rightPressed = false;

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _lastX = details.delta.dx;
      _lastY = details.delta.dy;
      _gestureStatus = "MOVE [dx: ${_lastX.toStringAsFixed(1)}, dy: ${_lastY.toStringAsFixed(1)}]";
    });
    _hid.sendMouseMove(details.delta.dx * _sensitivity, details.delta.dy * _sensitivity, 0, 0);
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() => _gestureStatus = "IDLE");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("USB Touchpad"),
        actions: [
          IconButton(
            tooltip: "Recalibrate Center",
            icon: const Icon(Icons.gps_fixed),
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() => _gestureStatus = "RE-CENTERED");
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top HUD Bar
            _buildHudBar(),

            // Sensitivity Selector Bar
            _buildSensitivitySelector(),

            // Main Trackpad Surface
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildTrackpadSurface(),
              ),
            ),

            // Physical Split Buttons (Left & Right Click)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: _buildPhysicalButtons(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHudBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.successGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "STATUS:",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _gestureStatus,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
          Text(
            "${_sensitivity}x DPI",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensitivitySelector() {
    final speeds = [0.5, 1.0, 1.5, 2.0, 3.0];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: speeds.map((s) {
          final isSelected = _sensitivity == s;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text("${s}x"),
              selected: isSelected,
              selectedColor: AppTheme.primaryBlue,
              backgroundColor: AppTheme.surfaceContainer,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppTheme.surface : AppTheme.onSurface,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: isSelected ? AppTheme.primaryBlue : AppTheme.outlineVariant),
              ),
              onSelected: (_) {
                HapticFeedback.selectionClick();
                setState(() => _sensitivity = s);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTrackpadSurface() {
    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _gestureStatus = "TAP (LEFT CLICK)");
        _hid.sendMouseClick(1);
      },
      onSecondaryTap: () {
        HapticFeedback.mediumImpact();
        setState(() => _gestureStatus = "2-FINGER (RIGHT CLICK)");
        _hid.sendMouseClick(2);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainer,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.outlineVariant, width: 1.5),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Decorative subtle crosshairs / center guide
            Icon(
              Icons.touch_app_outlined,
              size: 56,
              color: AppTheme.outline.withOpacity(0.3),
            ),
            Positioned(
              bottom: 16,
              child: Text(
                "Drag to move • Tap for Left Click • 2-Finger for Right Click",
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.onSurfaceVariant.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhysicalButtons() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTapDown: (_) {
              setState(() => _leftPressed = true);
              HapticFeedback.mediumImpact();
              _hid.sendMouseClick(1);
            },
            onTapUp: (_) => setState(() => _leftPressed = false),
            onTapCancel: () => setState(() => _leftPressed = false),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: _leftPressed ? AppTheme.primaryBlue : AppTheme.surfaceContainerHigh,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
                border: Border.all(color: AppTheme.outlineVariant),
              ),
              alignment: Alignment.center,
              child: Text(
                "LEFT CLICK",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: _leftPressed ? AppTheme.surface : AppTheme.onSurface,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: GestureDetector(
            onTapDown: (_) {
              setState(() => _rightPressed = true);
              HapticFeedback.mediumImpact();
              _hid.sendMouseClick(2);
            },
            onTapUp: (_) => setState(() => _rightPressed = false),
            onTapCancel: () => setState(() => _rightPressed = false),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: _rightPressed ? AppTheme.warningAmber : AppTheme.surfaceContainerHigh,
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(18)),
                border: Border.all(color: AppTheme.outlineVariant),
              ),
              alignment: Alignment.center,
              child: Text(
                "RIGHT CLICK",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: _rightPressed ? AppTheme.surface : AppTheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
