import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:barcode/barcode.dart' as barcode_lib;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:ui' as ui;
import '../models/scan_history_item.dart';
import '../services/hive_service.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class GeneratorScreen extends StatefulWidget {
  const GeneratorScreen({super.key});

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  final TextEditingController _textController = TextEditingController();
  final GlobalKey _qrKey = GlobalKey();
  String _selectedType = AppConstants.allTypes[0];
  String? _generatedData;
  bool _isGenerating = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _generateCode() {
    if (_textController.text.isEmpty) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        title: 'Empty Input',
        desc: 'Please enter some text to generate',
      ).show();
      return;
    }

    setState(() {
      _isGenerating = true;
      _generatedData = _textController.text;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    });
  }

  Future<void> _saveToHistory() async {
    if (_generatedData == null) return;

    final type = _selectedType.toLowerCase().contains('qr') ? 'qr' : 'barcode';
    final historyItem = ScanHistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      data: _generatedData!,
      type: type,
      timestamp: DateTime.now(),
      format: _selectedType,
    );
    await HiveService.saveHistoryItem(historyItem);

    if (!mounted) return;
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      title: 'Saved',
      desc: 'Code saved to history',
      autoHide: const Duration(seconds: 2),
    ).show();
  }

  Future<void> _downloadAsImage() async {
    if (_generatedData == null) return;

    try {
      final RenderRepaintBoundary boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/code_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);

      if (!mounted) return;
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        title: 'Downloaded',
        desc: 'Image saved to ${file.path}',
        autoHide: const Duration(seconds: 2),
      ).show();
    } catch (e) {
      if (!mounted) return;
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'Error',
        desc: 'Failed to save image: $e',
      ).show();
    }
  }

  Future<void> _shareCode() async {
    if (_generatedData == null) return;
    await Share.share(_generatedData!);
  }

  Widget _buildCodePreview() {
    if (_generatedData == null) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            'Generated code will appear here',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return RepaintBoundary(
      key: _qrKey,
      child: Neumorphic(
        style: NeumorphicStyle(
          shape: NeumorphicShape.convex,
          boxShape: NeumorphicBoxShape.roundRect(
            BorderRadius.circular(30),
          ),
          depth: 20,
          intensity: 0.8,
          color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFFFFFFF),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: _selectedType.toLowerCase().contains('qr')
              ? _buildQRCode()
              : _buildBarcode(),
        ),
      ),
    );
  }

  Widget _buildQRCode() {
    return QrImageView(
      data: _generatedData!,
      version: QrVersions.auto,
      size: 250,
      backgroundColor: Colors.white,
      errorCorrectionLevel: QrErrorCorrectLevel.M,
    );
  }

  Widget _buildBarcode() {
    barcode_lib.Barcode barcode;
    switch (_selectedType) {
      case 'Barcode Code128':
        barcode = barcode_lib.Barcode.code128();
        break;
      case 'Barcode EAN-13':
        barcode = barcode_lib.Barcode.ean13();
        break;
      case 'Barcode PDF417':
        barcode = barcode_lib.Barcode.pdf417();
        break;
      default:
        barcode = barcode_lib.Barcode.code128();
    }

    return BarcodeWidget(
      barcode: barcode,
      data: _generatedData!,
      width: 250,
      height: 100,
      color: Colors.black,
    );
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Generate Code',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 32),
                // Type dropdown
                Neumorphic(
                  style: NeumorphicStyle(
                    shape: NeumorphicShape.flat,
                    boxShape: NeumorphicBoxShape.roundRect(
                      BorderRadius.circular(20),
                    ),
                    depth: -4,
                    intensity: 0.8,
                    color: isDark
                        ? const Color(0xFF2D2D2D)
                        : const Color(0xFFFFFFFF),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: InputDecoration(
                      hintText: 'Select Type',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    items: AppConstants.allTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(
                          type,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                        _generatedData = null;
                      });
                    },
                    dropdownColor: isDark
                        ? const Color(0xFF2D2D2D)
                        : const Color(0xFFFFFFFF),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Text input
                Neumorphic(
                  style: NeumorphicStyle(
                    shape: NeumorphicShape.flat,
                    boxShape: NeumorphicBoxShape.roundRect(
                      BorderRadius.circular(20),
                    ),
                    depth: -4,
                    intensity: 0.8,
                    color: isDark
                        ? const Color(0xFF2D2D2D)
                        : const Color(0xFFFFFFFF),
                  ),
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Enter text to generate...',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(20),
                    ),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 3,
                  ),
                ),
                const SizedBox(height: 24),
                // Generate button
                NeumorphicButton(
                  onPressed: _isGenerating ? null : _generateCode,
                  style: NeumorphicStyle(
                    shape: NeumorphicShape.convex,
                    boxShape: NeumorphicBoxShape.roundRect(
                      BorderRadius.circular(20),
                    ),
                    depth: 12,
                    intensity: 0.8,
                    color: AppTheme.primaryColor,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Center(
                      child: _isGenerating
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Generate',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Preview
                _buildCodePreview(),
                if (_generatedData != null) ...[
                  const SizedBox(height: 24),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: NeumorphicButton(
                          onPressed: _downloadAsImage,
                          style: NeumorphicStyle(
                            shape: NeumorphicShape.convex,
                            boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.circular(15),
                            ),
                            depth: 8,
                            intensity: 0.8,
                            color: isDark
                                ? const Color(0xFF2D2D2D)
                                : const Color(0xFFFFFFFF),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.download, color: AppTheme.primaryColor),
                                const SizedBox(width: 8),
                                Text(
                                  'Download',
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: NeumorphicButton(
                          onPressed: _shareCode,
                          style: NeumorphicStyle(
                            shape: NeumorphicShape.convex,
                            boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.circular(15),
                            ),
                            depth: 8,
                            intensity: 0.8,
                            color: isDark
                                ? const Color(0xFF2D2D2D)
                                : const Color(0xFFFFFFFF),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.share, color: AppTheme.primaryColor),
                                const SizedBox(width: 8),
                                Text(
                                  'Share',
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  NeumorphicButton(
                    onPressed: _saveToHistory,
                    style: NeumorphicStyle(
                      shape: NeumorphicShape.convex,
                      boxShape: NeumorphicBoxShape.roundRect(
                        BorderRadius.circular(15),
                      ),
                      depth: 8,
                      intensity: 0.8,
                      color: isDark
                          ? const Color(0xFF2D2D2D)
                          : const Color(0xFFFFFFFF),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save, color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            'Save to History',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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

