import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:share_plus/share_plus.dart';
import '../services/hive_service.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _isSoundEnabled = true;
  bool _isVibrationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _isDarkMode = HiveService.isDarkMode();
      _isSoundEnabled = HiveService.isSoundEnabled();
      _isVibrationEnabled = HiveService.isVibrationEnabled();
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    await HiveService.setDarkMode(value);
    setState(() {
      _isDarkMode = value;
    });
    // Note: Theme change would require app restart or using a state management solution
    // For now, we just save the preference
  }

  Future<void> _toggleSound(bool value) async {
    await HiveService.setSoundEnabled(value);
    setState(() {
      _isSoundEnabled = value;
    });
  }

  Future<void> _toggleVibration(bool value) async {
    await HiveService.setVibrationEnabled(value);
    setState(() {
      _isVibrationEnabled = value;
    });
  }

  Future<void> _exportHistory() async {
    final items = HiveService.getHistoryItems();
    if (items.isEmpty) {
      if (!mounted) return;
      AwesomeDialog(
        context: context,
        dialogType: DialogType.info,
        title: 'No History',
        desc: 'There is no history to export',
      ).show();
      return;
    }

    final historyText = items.map((item) {
      return '${item.type.toUpperCase()}: ${item.data}\nDate: ${item.formattedDate}\n---\n';
    }).join('\n');

    await Share.share(historyText);
  }

  Future<void> _deleteAllData() async {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: 'Delete All Data',
      desc: 'Are you sure you want to delete all history and settings? This action cannot be undone.',
      btnOkText: 'Delete',
      btnOkColor: Colors.red,
      btnOkOnPress: () async {
        await HiveService.clearAllHistory();
        await HiveService.setDarkMode(false);
        await HiveService.setSoundEnabled(true);
        await HiveService.setVibrationEnabled(true);
        if (!mounted) return;
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          title: 'Success',
          desc: 'All data deleted',
          autoHide: const Duration(seconds: 2),
        ).show();
        _loadSettings();
      },
      btnCancelText: 'Cancel',
      btnCancelOnPress: () {},
    ).show();
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
                  'Settings',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 32),
                // Theme switch
                _buildSettingTile(
                  context,
                  icon: Icons.dark_mode,
                  title: 'Dark Mode',
                  subtitle: 'Switch between light and dark theme',
                  trailing: _buildNeumorphicSwitch(
                    context,
                    value: _isDarkMode,
                    onChanged: _toggleDarkMode,
                  ),
                ),
                const SizedBox(height: 16),
                // Sound toggle
                _buildSettingTile(
                  context,
                  icon: Icons.volume_up,
                  title: 'Sound',
                  subtitle: 'Enable/disable sound effects',
                  trailing: _buildNeumorphicSwitch(
                    context,
                    value: _isSoundEnabled,
                    onChanged: _toggleSound,
                  ),
                ),
                const SizedBox(height: 16),
                // Vibration toggle
                _buildSettingTile(
                  context,
                  icon: Icons.vibration,
                  title: 'Vibration',
                  subtitle: 'Enable/disable vibration feedback',
                  trailing: _buildNeumorphicSwitch(
                    context,
                    value: _isVibrationEnabled,
                    onChanged: _toggleVibration,
                  ),
                ),
                const SizedBox(height: 32),
                // About section
                Text(
                  'About',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSettingTile(
                  context,
                  icon: Icons.info,
                  title: 'App Version',
                  subtitle: AppConstants.appVersion,
                  trailing: null,
                ),
                const SizedBox(height: 32),
                // Actions
                Text(
                  'Actions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                NeumorphicButton(
                  onPressed: _exportHistory,
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
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload, color: AppTheme.primaryColor),
                        const SizedBox(width: 12),
                        Text(
                          'Export History',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                NeumorphicButton(
                  onPressed: _deleteAllData,
                  style: NeumorphicStyle(
                    shape: NeumorphicShape.convex,
                    boxShape: NeumorphicBoxShape.roundRect(
                      BorderRadius.circular(15),
                    ),
                    depth: 8,
                    intensity: 0.8,
                    color: Colors.red.withValues(alpha: 0.1),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.delete_forever, color: Colors.red),
                        const SizedBox(width: 12),
                        Text(
                          'Delete All Data',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.convex,
        boxShape: NeumorphicBoxShape.roundRect(
          BorderRadius.circular(20),
        ),
        depth: 8,
        intensity: 0.8,
        color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFFFFFFF),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        trailing: trailing,
      ),
    );
  }

  Widget _buildNeumorphicSwitch(
    BuildContext context, {
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return NeumorphicSwitch(
      value: value,
      onChanged: onChanged,
      style: NeumorphicSwitchStyle(
        activeTrackColor: AppTheme.primaryColor,
        inactiveTrackColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFE0E0E0),
        activeThumbColor: Colors.white,
        inactiveThumbColor: Colors.white,
      ),
    );
  }
}

