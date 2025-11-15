import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../models/scan_history_item.dart';
import '../services/hive_service.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';
import 'history_detail_screen.dart';

class GalleryScanScreen extends StatefulWidget {
  const GalleryScanScreen({super.key});

  @override
  State<GalleryScanScreen> createState() => _GalleryScanScreenState();
}

class _GalleryScanScreenState extends State<GalleryScanScreen> {
  XFile? _selectedImage;
  bool _isScanning = false;
  String? _scannedData;
  String? _scannedType;
  String? _scannedFormat;

  final ImagePicker _picker = ImagePicker();
  final MobileScannerController _controller = MobileScannerController();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
          _scannedData = null;
        });
        _scanImage(image.path);
      }
    } catch (e) {
      if (!mounted) return;
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'Error',
        desc: 'Failed to pick image: $e',
      ).show();
    }
  }

  Future<void> _scanImage(String imagePath) async {
    setState(() {
      _isScanning = true;
    });

    try {
      // Use MobileScanner to analyze the image file
      final file = File(imagePath);
      if (!await file.exists()) {
        setState(() {
          _isScanning = false;
        });
        if (!mounted) return;
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          title: 'Error',
          desc: 'Image file not found',
        ).show();
        return;
      }

      // Create a temporary scanner to analyze the image
      final scanner = MobileScannerController();
      
      // Use the analyzeImage method if available, otherwise use alternative approach
      try {
        final result = await scanner.analyzeImage(imagePath);
        if (result != null && result.barcodes.isNotEmpty) {
          final barcode = result.barcodes.first;
          final String? rawValue = barcode.rawValue;

          if (rawValue != null && rawValue.isNotEmpty) {
            setState(() {
              _scannedData = rawValue;
              final typeName = barcode.type.name.toLowerCase();
              _scannedType = typeName.contains('qr') ? 'qr' : 'barcode';
              _scannedFormat = barcode.type.name;
              _isScanning = false;
            });

            // Save to history
            final historyItem = ScanHistoryItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              data: rawValue,
              type: _scannedType!,
              timestamp: DateTime.now(),
              format: _scannedFormat,
            );
            await HiveService.saveHistoryItem(historyItem);

            if (!mounted) return;
            _showResultBottomSheet();
            await scanner.dispose();
            return;
          }
        }
        await scanner.dispose();
      } catch (e) {
        await scanner.dispose();
        // If analyzeImage doesn't work, show error
        throw Exception('Failed to analyze image: $e');
      }

      setState(() {
        _isScanning = false;
      });
      if (!mounted) return;
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        title: 'No Code Found',
        desc: 'Could not detect any QR code or barcode in this image',
      ).show();
    } catch (e) {
      setState(() {
        _isScanning = false;
      });
      if (!mounted) return;
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'Error',
        desc: 'Failed to scan image: $e',
      ).show();
    }
  }

  void _showResultBottomSheet() {
    if (_scannedData == null) return;
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
                _scannedType == 'qr' ? Icons.qr_code : Icons.qr_code_2,
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
                Helpers.getCodeType(_scannedData!),
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
                  _scannedData!,
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
                      onPressed: () => _handleOpen(_scannedData!),
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
                      onPressed: () => _handleCopy(_scannedData!),
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
                      onPressed: () => _handleShare(_scannedData!),
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
                                data: _scannedData!,
                                type: _scannedType!,
                                timestamp: DateTime.now(),
                                format: _scannedFormat,
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1A1A1A),
                    const Color(0xFF2D2D2D),
                  ]
                : [
                    const Color(0xFFE0E0E0),
                    const Color(0xFFF5F5F5),
                  ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isScanning ? null : _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? const Color(0xFF2D2D2D)
                        : const Color(0xFFFFFFFF),
                    foregroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 20,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.photo_library,
                        size: 32,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Pick Image From Gallery',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                if (_selectedImage != null) ...[
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: isDark
                          ? const Color(0xFF2D2D2D)
                          : const Color(0xFFFFFFFF),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        File(_selectedImage!.path),
                        width: 300,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_isScanning)
                    const CircularProgressIndicator()
                  else if (_scannedData != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF2D2D2D)
                            : const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Code detected!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}


