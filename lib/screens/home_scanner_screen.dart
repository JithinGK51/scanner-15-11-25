import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../models/scan_history_item.dart';
import '../services/hive_service.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';
import 'history_detail_screen.dart';

class HomeScannerScreen extends StatefulWidget {
  const HomeScannerScreen({super.key});

  @override
  State<HomeScannerScreen> createState() => _HomeScannerScreenState();
}

class _HomeScannerScreenState extends State<HomeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  bool _isTorchOn = false;
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_isProcessing) return;
    _isProcessing = true;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) {
      _isProcessing = false;
      return;
    }

    final barcode = barcodes.first;
    final String? rawValue = barcode.rawValue;

    if (rawValue == null || rawValue.isEmpty) {
      _isProcessing = false;
      return;
    }

    // Haptic feedback
    if (HiveService.isVibrationEnabled()) {
      HapticFeedback.mediumImpact();
    }

    // Determine type
    String type = 'qr';
    String? format;
    final typeName = barcode.type.name.toLowerCase();
    if (!typeName.contains('qr')) {
      type = 'barcode';
      format = barcode.type.name;
    }

    // Save to history
    final historyItem = ScanHistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      data: rawValue,
      type: type,
      timestamp: DateTime.now(),
      format: format,
    );
    await HiveService.saveHistoryItem(historyItem);

    // Show bottom sheet
    if (!mounted) return;
    _showResultBottomSheet(rawValue, type, format);

    _isProcessing = false;
  }

  void _showResultBottomSheet(String data, String type, String? format) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFFFFFFF),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Icon(
                type == 'qr' ? Icons.qr_code : Icons.qr_code_2,
                size: 60,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Code Detected',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                Helpers.getCodeType(data),
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SelectableText(
                  data,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleOpen(data),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? const Color(0xFF2D2D2D)
                            : const Color(0xFFFFFFFF),
                        foregroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.open_in_new, color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          const Text(
                            'Open',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleCopy(data),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? const Color(0xFF2D2D2D)
                            : const Color(0xFFFFFFFF),
                        foregroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.copy, color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          const Text(
                            'Copy',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleShare(data),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? const Color(0xFF2D2D2D)
                            : const Color(0xFFFFFFFF),
                        foregroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.share, color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          const Text(
                            'Share',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HistoryDetailScreen(
                              item: ScanHistoryItem(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                data: data,
                                type: type,
                                timestamp: DateTime.now(),
                                format: format,
                              ),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? const Color(0xFF2D2D2D)
                            : const Color(0xFFFFFFFF),
                        foregroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.visibility, color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          const Text(
                            'Details',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleOpen(String data) async {
    Navigator.pop(context);
    if (Helpers.isValidURL(data)) {
      final launched = await Helpers.launchURL(data);
      if (!launched && mounted) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          title: 'Error',
          desc: 'Could not open URL',
        ).show();
      }
    } else if (Helpers.isUPI(data)) {
      final launched = await Helpers.launchURL(data);
      if (!launched && mounted) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.info,
          title: 'UPI Payment',
          desc: 'Please use a UPI app to process this payment',
        ).show();
      }
    } else {
      if (!mounted) return;
      AwesomeDialog(
        context: context,
        dialogType: DialogType.info,
        title: 'Text Content',
        desc: data,
      ).show();
    }
  }

  Future<void> _handleCopy(String data) async {
    await Helpers.copyToClipboard(data);
    if (!mounted) return;
    Navigator.pop(context);
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      title: 'Copied',
      desc: 'Data copied to clipboard',
      autoHide: const Duration(seconds: 2),
    ).show();
  }

  Future<void> _handleShare(String data) async {
    Navigator.pop(context);
    await Helpers.shareText(data);
  }

  void _toggleTorch() {
    setState(() {
      _isTorchOn = !_isTorchOn;
    });
    _controller.toggleTorch();
  }

  void _switchCamera() {
    _controller.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          // Camera view
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
          ),
          // Overlay with glow effect
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.8,
                colors: [
                  Colors.transparent,
                  isDark
                      ? Colors.black.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.1),
                ],
              ),
            ),
          ),
          // Corner borders
          _buildCornerBorders(isDark),
          // Top controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _switchCamera,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? const Color(0xFF2D2D2D)
                          : const Color(0xFFFFFFFF),
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12.0),
                      elevation: 8,
                    ),
                    child: const Icon(Icons.cameraswitch, color: Colors.white),
                  ),
                  ElevatedButton(
                    onPressed: _toggleTorch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? const Color(0xFF2D2D2D)
                          : const Color(0xFFFFFFFF),
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12.0),
                      elevation: 8,
                    ),
                    child: Icon(
                      _isTorchOn ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom gallery button
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  // This will be handled by bottom navigation
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? const Color(0xFF2D2D2D)
                      : const Color(0xFFFFFFFF),
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(0),
                  minimumSize: const Size(70, 70),
                  elevation: 12,
                ),
                child: Icon(
                  Icons.photo_library,
                  color: AppTheme.primaryColor,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCornerBorders(bool isDark) {
    return Stack(
      children: [
        // Top left
        Positioned(
          top: 100,
          left: 50,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppTheme.neonBlue,
                  width: 4,
                ),
                left: BorderSide(
                  color: AppTheme.neonBlue,
                  width: 4,
                ),
              ),
            ),
          ),
        ),
        // Top right
        Positioned(
          top: 100,
          right: 50,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppTheme.neonBlue,
                  width: 4,
                ),
                right: BorderSide(
                  color: AppTheme.neonBlue,
                  width: 4,
                ),
              ),
            ),
          ),
        ),
        // Bottom left
        Positioned(
          bottom: 200,
          left: 50,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.neonBlue,
                  width: 4,
                ),
                left: BorderSide(
                  color: AppTheme.neonBlue,
                  width: 4,
                ),
              ),
            ),
          ),
        ),
        // Bottom right
        Positioned(
          bottom: 200,
          right: 50,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.neonBlue,
                  width: 4,
                ),
                right: BorderSide(
                  color: AppTheme.neonBlue,
                  width: 4,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

