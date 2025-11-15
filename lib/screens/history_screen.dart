import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../models/scan_history_item.dart';
import '../services/hive_service.dart';
import '../utils/app_theme.dart';
import 'history_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ScanHistoryItem> _historyItems = [];
  List<ScanHistoryItem> _filteredItems = [];
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'latest';

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _searchController.addListener(_filterHistory);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadHistory() {
    setState(() {
      _historyItems = HiveService.getHistoryItems();
      _filteredItems = _historyItems;
      _sortHistory();
    });
  }

  void _filterHistory() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = _historyItems;
      } else {
        _filteredItems = _historyItems
            .where((item) =>
                item.data.toLowerCase().contains(query) ||
                item.type.toLowerCase().contains(query))
            .toList();
      }
      _sortHistory();
    });
  }

  void _sortHistory() {
    setState(() {
      switch (_sortBy) {
        case 'latest':
          _filteredItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          break;
        case 'oldest':
          _filteredItems.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          break;
        case 'type':
          _filteredItems.sort((a, b) => a.type.compareTo(b.type));
          break;
      }
    });
  }

  Future<void> _deleteItem(String id) async {
    await HiveService.deleteHistoryItem(id);
    _loadHistory();
  }

  Future<void> _clearAllHistory() async {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: 'Clear All History',
      desc: 'Are you sure you want to delete all history? This action cannot be undone.',
      btnOkText: 'Clear',
      btnOkColor: Colors.red,
      btnOkOnPress: () async {
        await HiveService.clearAllHistory();
        _loadHistory();
        if (!mounted) return;
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          title: 'Success',
          desc: 'All history cleared',
          autoHide: const Duration(seconds: 2),
        ).show();
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Neumorphic(
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
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search history...',
                            prefixIcon: Icon(
                              Icons.search,
                              color: AppTheme.primaryColor,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    NeumorphicButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (context) => _buildSortBottomSheet(isDark),
                        );
                      },
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
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Icon(Icons.sort, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              if (_filteredItems.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 80,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No history yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Dismissible(
                          key: Key(item.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          onDismissed: (direction) {
                            _deleteItem(item.id);
                          },
                          child: Neumorphic(
                            style: NeumorphicStyle(
                              shape: NeumorphicShape.convex,
                              boxShape: NeumorphicBoxShape.roundRect(
                                BorderRadius.circular(20),
                              ),
                              depth: 8,
                              intensity: 0.8,
                              color: isDark
                                  ? const Color(0xFF2D2D2D)
                                  : const Color(0xFFFFFFFF),
                            ),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  item.type == 'qr'
                                      ? Icons.qr_code
                                      : Icons.qr_code_2,
                                  color: AppTheme.primaryColor,
                                  size: 28,
                                ),
                              ),
                              title: Text(
                                item.data.length > 50
                                    ? '${item.data.substring(0, 50)}...'
                                    : item.data,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${item.type.toUpperCase()} • ${item.formattedDate}',
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : Colors.black54,
                                ),
                              ),
                              trailing: Icon(
                                Icons.chevron_right,
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => HistoryDetailScreen(item: item),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              if (_filteredItems.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: NeumorphicButton(
                    onPressed: _clearAllHistory,
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
                      child: Center(
                        child: Text(
                          'Clear All History',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortBottomSheet(bool isDark) {
    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(
          const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        depth: 20,
        intensity: 0.8,
        color: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFFFFFFF),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sort By',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            _buildSortOption(isDark, 'Latest', 'latest'),
            _buildSortOption(isDark, 'Oldest', 'oldest'),
            _buildSortOption(isDark, 'Type', 'type'),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(bool isDark, String title, String value) {
    final isSelected = _sortBy == value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: NeumorphicButton(
        onPressed: () {
          setState(() {
            _sortBy = value;
          });
          _sortHistory();
          Navigator.pop(context);
        },
        style: NeumorphicStyle(
          shape: NeumorphicShape.convex,
          boxShape: NeumorphicBoxShape.roundRect(
            BorderRadius.circular(15),
          ),
          depth: isSelected ? 8 : 4,
          intensity: 0.8,
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.2)
              : (isDark ? const Color(0xFF2D2D2D) : const Color(0xFFFFFFFF)),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? AppTheme.primaryColor
                      : (isDark ? Colors.white : Colors.black87),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check,
                  color: AppTheme.primaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

