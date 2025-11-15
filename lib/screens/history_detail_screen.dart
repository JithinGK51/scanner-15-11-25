import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../models/scan_history_item.dart';
import '../services/hive_service.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';

class HistoryDetailScreen extends StatelessWidget {
  final ScanHistoryItem item;

  const HistoryDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Code preview
                Neumorphic(
                  style: NeumorphicStyle(
                    shape: NeumorphicShape.convex,
                    boxShape: NeumorphicBoxShape.roundRect(
                      BorderRadius.circular(30),
                    ),
                    depth: 20,
                    intensity: 0.8,
                    color: isDark
                        ? const Color(0xFF2D2D2D)
                        : const Color(0xFFFFFFFF),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          item.type == 'qr' ? Icons.qr_code : Icons.qr_code_2,
                          size: 100,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          item.type.toUpperCase(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        if (item.format != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Format: ${item.format}',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Data container
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
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SelectableText(
                          item.data,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Divider(color: isDark ? Colors.white24 : Colors.black12),
                        const SizedBox(height: 8),
                        Text(
                          'Scanned: ${item.formattedDate}',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: NeumorphicButton(
                        onPressed: () => _handleCopy(context),
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
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.copy, color: AppTheme.primaryColor),
                              const SizedBox(width: 8),
                              Text(
                                'Copy',
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
                        onPressed: () => _handleShare(context),
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
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
                Row(
                  children: [
                    Expanded(
                      child: NeumorphicButton(
                        onPressed: () => _handleOpen(context),
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
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.open_in_new, color: AppTheme.primaryColor),
                              const SizedBox(width: 8),
                              Text(
                                'Open',
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
                        onPressed: () => _handleDelete(context),
                        style: NeumorphicStyle(
                          shape: NeumorphicShape.convex,
                          boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(15),
                          ),
                          depth: 8,
                          intensity: 0.8,
                          color: Colors.red.withValues(alpha: 0.1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.delete, color: Colors.red),
                              const SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(
                                  color: Colors.red,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleCopy(BuildContext context) async {
    await Helpers.copyToClipboard(item.data);
    if (!context.mounted) return;
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      title: 'Copied',
      desc: 'Data copied to clipboard',
      autoHide: const Duration(seconds: 2),
    ).show();
  }

  Future<void> _handleShare(BuildContext context) async {
    await Helpers.shareText(item.data);
  }

  Future<void> _handleOpen(BuildContext context) async {
    if (Helpers.isValidURL(item.data)) {
      final launched = await Helpers.launchURL(item.data);
      if (!launched && context.mounted) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          title: 'Error',
          desc: 'Could not open URL',
        ).show();
      }
    } else if (Helpers.isUPI(item.data)) {
      final launched = await Helpers.launchURL(item.data);
      if (!launched && context.mounted) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.info,
          title: 'UPI Payment',
          desc: 'Please use a UPI app to process this payment',
        ).show();
      }
    } else {
      if (!context.mounted) return;
      AwesomeDialog(
        context: context,
        dialogType: DialogType.info,
        title: 'Text Content',
        desc: item.data,
      ).show();
    }
  }

  Future<void> _handleDelete(BuildContext context) async {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: 'Delete Item',
      desc: 'Are you sure you want to delete this item?',
      btnOkText: 'Delete',
      btnOkColor: Colors.red,
      btnOkOnPress: () async {
        await HiveService.deleteHistoryItem(item.id);
        if (!context.mounted) return;
        Navigator.pop(context);
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          title: 'Deleted',
          desc: 'Item deleted successfully',
          autoHide: const Duration(seconds: 2),
        ).show();
      },
      btnCancelText: 'Cancel',
      btnCancelOnPress: () {},
    ).show();
  }
}

