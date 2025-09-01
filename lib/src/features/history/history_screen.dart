import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/qr_history_item.dart';
import '../../services/qr_history_service.dart';
import '../qr_generator/qr_generator_screen.dart';
import '../qr_generator/models/qr_generator_data.dart';
import 'widgets/history_item_card.dart';
import 'widgets/history_filter_sheet.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final QRHistoryService _historyService = QRHistoryService();
  final TextEditingController _searchController = TextEditingController();
  
  List<QRHistoryItem> _allHistoryItems = [];
  List<QRHistoryItem> _filteredHistoryItems = [];
  QRHistoryType? _selectedFilter;
  bool _isLoading = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final items = await _historyService.getAllQRHistory();
      setState(() {
        _allHistoryItems = items;
        _filteredHistoryItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _allHistoryItems = [];
        _filteredHistoryItems = [];
      });
      _showErrorSnackBar('Failed to load history: $e');
    }
  }

  void _filterHistory() {
    setState(() {
      if (_selectedFilter != null) {
        _filteredHistoryItems = _allHistoryItems
            .where((item) => item.type == _selectedFilter)
            .toList();
      } else {
        _filteredHistoryItems = _allHistoryItems;
      }
    });
  }

  void _searchHistory(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _filteredHistoryItems = _allHistoryItems;
      } else {
        _filteredHistoryItems = _allHistoryItems
            .where((item) =>
                item.content.toLowerCase().contains(query.toLowerCase()) ||
                (item.title?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
                (item.description?.toLowerCase().contains(query.toLowerCase()) ?? false))
            .toList();
      }
    });
  }

  Future<void> _deleteHistoryItem(QRHistoryItem item) async {
    try {
      await _historyService.deleteQRHistory(item.id);
      setState(() {
        _allHistoryItems.removeWhere((element) => element.id == item.id);
        _filteredHistoryItems.removeWhere((element) => element.id == item.id);
      });
      _showSuccessSnackBar('Item deleted successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to delete item: $e');
    }
  }

  Future<void> _shareHistoryItem(QRHistoryItem item) async {
    try {
      await Share.share(
        'QR Code Content: ${item.content}',
        subject: 'QR Code from History',
      );
    } catch (e) {
      _showErrorSnackBar('Failed to share: $e');
    }
  }

  void _reuseHistoryItem(QRHistoryItem item) {
    if (item.type == QRHistoryType.generated && item.qrData != null) {
      // Create QRGeneratorData with the original content and colors
      final qrData = QRGeneratorData(
        qrContent: item.content,
        backgroundColor: item.qrData!.backgroundColor,
        foregroundColor: item.qrData!.foregroundColor,
        originalType: item.qrData!.originalType,
        originalText: item.qrData!.originalText,
        originalUrl: item.qrData!.originalUrl,
        originalPhone: item.qrData!.originalPhone,
        originalSsid: item.qrData!.originalSsid,
        originalPassword: item.qrData!.originalPassword,
        originalName: item.qrData!.originalName,
        originalEmail: item.qrData!.originalEmail,
      );
      
      // Navigate to QR generator with the saved data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QRGeneratorScreen(initialData: qrData),
        ),
      );
    } else {
      // For scanned items, copy to clipboard
      Clipboard.setData(ClipboardData(text: item.content));
      _showSuccessSnackBar('Content copied to clipboard');
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => HistoryFilterSheet(
        selectedFilter: _selectedFilter,
        onFilterChanged: (filter) {
          setState(() {
            _selectedFilter = filter;
          });
          _filterHistory();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.delete_forever,
                color: Color(0xFFEF4444),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Clear All History',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete all QR code history? This action cannot be undone.',
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAllHistory();
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Delete All',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAllHistory() async {
    try {
      await _historyService.deleteAllQRHistory();
      setState(() {
        _allHistoryItems.clear();
        _filteredHistoryItems.clear();
      });
      _showSuccessSnackBar('All history cleared successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to clear history: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'History',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_allHistoryItems.isNotEmpty)
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.filter_list,
                  color: Color(0xFF8B5CF6),
                  size: 20,
                ),
              ),
              onPressed: _showFilterSheet,
            ),
          if (_allHistoryItems.isNotEmpty)
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.delete_sweep,
                  color: Color(0xFFEF4444),
                  size: 20,
                ),
              ),
              onPressed: _showDeleteAllDialog,
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _searchHistory,
              decoration: InputDecoration(
                hintText: 'Search QR codes...',
                prefixIcon: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.search,
                    color: Color(0xFF3B82F6),
                    size: 20,
                  ),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchHistory('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),

          // Filter Chip
          if (_selectedFilter != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedFilter == QRHistoryType.scanned ? 'Scanned' : 'Generated',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedFilter = null;
                            });
                            _filterHistory();
                          },
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // History List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF3B82F6),
                    ),
                  )
                : _filteredHistoryItems.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadHistory,
                        color: const Color(0xFF3B82F6),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredHistoryItems.length,
                          itemBuilder: (context, index) {
                            final item = _filteredHistoryItems[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: HistoryItemCard(
                                item: item,
                                onDelete: () => _deleteHistoryItem(item),
                                onShare: () => _shareHistoryItem(item),
                                onReuse: () => _reuseHistoryItem(item),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              _isSearching ? Icons.search_off : Icons.history,
              size: 64,
              color: const Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _isSearching ? 'No results found' : 'No QR codes yet',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isSearching
                ? 'Try adjusting your search terms'
                : 'Start by scanning or generating QR codes',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          if (!_isSearching) ...[
            const SizedBox(height: 32),
            Container(
              width: 200,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF667EEA),
                    Color(0xFF764BA2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Start Scanning',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
