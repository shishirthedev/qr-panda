import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/app_theme.dart';
import '../../models/qr_history_item.dart';
import '../../services/ad_service.dart';
import '../../services/premium_service.dart';
import '../../services/qr_history_service.dart';
import '../qr_generator/qr_generator_screen.dart';
import '../qr_generator/models/qr_generator_data.dart';
import 'widgets/history_item_card.dart';

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
  int _filterIndex = 0; // 0=All, 1=Scanned, 2=Generated
  bool _isLoading = true;
  bool _isSearching = false;

  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    if (AdService.instance.adsReadyNotifier.value) {
      _loadBanner();
    } else {
      AdService.instance.adsReadyNotifier.addListener(_onAdsReady);
    }
  }

  void _onAdsReady() {
    AdService.instance.adsReadyNotifier.removeListener(_onAdsReady);
    _loadBanner();
  }

  void _loadBanner() {
    if (PremiumService.instance.isPremium) return;
    final config = AdService.instance.config;
    if (!config.bannerAdsEnabled || config.bannerAdUnitId.isEmpty) return;
    BannerAd(
      adUnitId: config.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _bannerAd = ad as BannerAd);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('[History] Banner failed: ${error.message}');
          ad.dispose();
        },
      ),
    ).load();
  }

  @override
  void dispose() {
    AdService.instance.adsReadyNotifier.removeListener(_onAdsReady);
    _bannerAd?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final items = await _historyService.getAllQRHistory();
      setState(() {
        _allHistoryItems = items;
        _applyFilter();
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

  void _applyFilter() {
    final query = _searchController.text.toLowerCase();
    List<QRHistoryItem> base;

    if (_filterIndex == 1) {
      base = _allHistoryItems.where((i) => i.type == QRHistoryType.scanned).toList();
    } else if (_filterIndex == 2) {
      base = _allHistoryItems.where((i) => i.type == QRHistoryType.generated).toList();
    } else {
      base = _allHistoryItems;
    }

    if (query.isNotEmpty) {
      base = base
          .where((item) =>
              item.content.toLowerCase().contains(query) ||
              (item.title?.toLowerCase().contains(query) ?? false) ||
              (item.description?.toLowerCase().contains(query) ?? false))
          .toList();
    }

    _filteredHistoryItems = base;
    _isSearching = query.isNotEmpty;
  }

  void _searchHistory(String query) {
    setState(() => _applyFilter());
  }

  void _setFilter(int index) {
    setState(() {
      _filterIndex = index;
      _applyFilter();
    });
  }

  Future<void> _deleteHistoryItem(QRHistoryItem item) async {
    try {
      await _historyService.deleteQRHistory(item.id);
      setState(() {
        _allHistoryItems.removeWhere((e) => e.id == item.id);
        _applyFilter();
      });
      _showSuccessSnackBar('Item deleted successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to delete item: $e');
    }
  }

  Future<void> _shareHistoryItem(QRHistoryItem item) async {
    try {
      await Share.share('QR Code Content: ${item.content}',
          subject: 'QR Code from History');
    } catch (e) {
      _showErrorSnackBar('Failed to share: $e');
    }
  }

  void _reuseHistoryItem(QRHistoryItem item) {
    if (item.type == QRHistoryType.generated && item.qrData != null) {
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QRGeneratorScreen(initialData: qrData),
        ),
      );
    } else {
      Clipboard.setData(ClipboardData(text: item.content));
      _showSuccessSnackBar('Content copied to clipboard');
    }
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

  void _showDeleteAllSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: kSurface2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: kBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: kRose.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.delete_forever, color: kRose, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              'Delete All History?',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: kText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'This action cannot be undone. All your scan and generate history will be removed.',
              style: GoogleFonts.inter(fontSize: 14, color: kText2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                _deleteAllHistory();
              },
              child: Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  color: kRose,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    'Delete All',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(fontSize: 14, color: kText2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  int get _scannedCount => _allHistoryItems.where((i) => i.type == QRHistoryType.scanned).length;
  int get _generatedCount => _allHistoryItems.where((i) => i.type == QRHistoryType.generated).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: kSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kBorder),
                      ),
                      child: const Icon(Icons.arrow_back, color: kText, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'History',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                      color: kText,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.filter_list, color: kText2),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kBorder, width: 1),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _searchHistory,
                  style: GoogleFonts.inter(fontSize: 14, color: kText),
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: GoogleFonts.inter(color: kTextMuted),
                    prefixIcon:
                        const Icon(Icons.search, color: kTextMuted, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                color: kTextMuted, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _searchHistory('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Filter chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildFilterChip(0, 'All', _allHistoryItems.length),
                  const SizedBox(width: 8),
                  _buildFilterChip(1, 'Scanned', _scannedCount),
                  const SizedBox(width: 8),
                  _buildFilterChip(2, 'Generated', _generatedCount),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: kPrimary))
                  : _filteredHistoryItems.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadHistory,
                          color: kPrimary,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            itemCount: _filteredHistoryItems.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = _filteredHistoryItems[index];
                              return Dismissible(
                                key: Key(item.id),
                                direction: DismissDirection.endToStart,
                                onDismissed: (_) => _deleteHistoryItem(item),
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  decoration: BoxDecoration(
                                    color: kRose.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child:
                                      const Icon(Icons.delete, color: kRose),
                                ),
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
            if (_bannerAd != null)
              Positioned(
                left: 0, right: 0, bottom: 0,
                child: SizedBox(
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: _allHistoryItems.isNotEmpty
          ? GestureDetector(
              onTap: _showDeleteAllSheet,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: kRose,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: kRose.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.delete_sweep, color: Colors.white),
              ),
            )
          : null,
    );
  }

  Widget _buildFilterChip(int index, String label, int count) {
    final isSelected = _filterIndex == index;
    return GestureDetector(
      onTap: () => _setFilter(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(colors: [kPrimaryDark, kPrimary])
              : null,
          color: isSelected ? null : kSurface,
          borderRadius: BorderRadius.circular(10),
          border: isSelected ? null : Border.all(color: kBorder, width: 1),
          boxShadow: isSelected
              ? [
                  const BoxShadow(
                      color: kPrimaryGlow, blurRadius: 12, offset: Offset(0, 4))
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : kText2,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              height: 18,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : kSurface2,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Center(
                child: Text(
                  '$count',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : kText2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(Icons.history, size: 48, color: kTextMuted),
            ),
            const SizedBox(height: 24),
            Text(
              _isSearching ? 'No results found' : 'No history yet',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: kText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _isSearching
                  ? 'Try adjusting your search terms'
                  : 'Start scanning or creating QR codes',
              style: GoogleFonts.inter(fontSize: 14, color: kText2),
              textAlign: TextAlign.center,
            ),
            if (!_isSearching) ...[
              const SizedBox(height: 28),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [kPrimaryDark, kPrimary, kPrimaryLight]),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                          color: kPrimaryGlow,
                          blurRadius: 20,
                          offset: Offset(0, 6))
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Scan a Code',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
