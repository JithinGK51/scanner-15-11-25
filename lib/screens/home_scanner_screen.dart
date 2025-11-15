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
      try {
        final launched = await Helpers.launchURL(data);
        if (!launched && mounted) {
          _showErrorDialog('Could not open URL. Please check if the URL is valid or try again.');
        }
      } catch (e) {
        if (mounted) {
          _showErrorDialog('Could not open URL. Please check if the URL is valid or try again.');
        }
      }
    } else if (Helpers.isUPI(data)) {
      try {
        final launched = await Helpers.launchURL(data);
        if (!launched && mounted) {
          _showInfoDialog('UPI Payment', 'Please use a UPI app to process this payment');
        }
      } catch (e) {
        if (mounted) {
          _showInfoDialog('UPI Payment', 'Please use a UPI app to process this payment');
        }
      }
    } else {
      if (!mounted) return;
      _showInfoDialog('Text Content', data);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Error', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera view
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
          ),
          // Dark overlay with scanning area cutout
          _buildOverlay(),
          // Central scanning frame with rounded corners
          _buildScanningFrame(),
          // Blue dot in center
          _buildCenterDot(),
          // Top controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildControlButton(
                    icon: Icons.cameraswitch,
                    onPressed: _switchCamera,
                  ),
                  _buildControlButton(
                    icon: _isTorchOn ? Icons.flash_on : Icons.flash_off,
                    onPressed: _toggleTorch,
                  ),
                ],
              ),
            ),
          ),
          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // First row: Edit and Torch buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildBottomControlButton(
                          icon: Icons.edit,
                          onPressed: () {
                            // Manual input functionality
                          },
                        ),
                        _buildBottomControlButton(
                          icon: _isTorchOn ? Icons.flash_on : Icons.flash_off,
                          onPressed: _toggleTorch,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Large capture button
                    _buildCaptureButton(),
                    const SizedBox(height: 20),
                    // Third row: Keyboard, Layers, Gallery
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildBottomControlButton(
                          icon: Icons.keyboard,
                          onPressed: () {
                            // Keyboard input
                          },
                        ),
                        _buildBottomControlButton(
                          icon: Icons.layers,
                          onPressed: () {
                            // Layers functionality
                          },
                        ),
                        _buildBottomControlButton(
                          icon: Icons.photo_library,
                          onPressed: () {
                            // Gallery functionality
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return CustomPaint(
      painter: ScannerOverlayPainter(),
    );
  }

  Widget _buildScanningFrame() {
    return Center(
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.8),
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildCenterDot() {
    return Center(
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.primaryColor,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.8),
              blurRadius: 12,
              spreadRadius: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.2),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 24),
        padding: const EdgeInsets.all(12),
      ),
    );
  }

  Widget _buildBottomControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.15),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: () {
        // Capture/scan action
      },
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.primaryColor,
          border: Border.all(
            color: Colors.white,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.75)
      ..style = PaintingStyle.fill;

    // Draw dark overlay covering entire screen
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Cut out scanning area (center square with rounded corners)
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scanSize = 280.0;
    final scanRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: scanSize,
        height: scanSize,
      ),
      const Radius.circular(24),
    );

    final cutoutPath = Path()
      ..addRRect(scanRect);

    // Use PathOperation to cut out the scanning area
    final combinedPath = Path.combine(
      PathOperation.difference,
      overlayPath,
      cutoutPath,
    );

    canvas.drawPath(combinedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
