import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_theme.dart';
import '../../../models/qr_history_item.dart';
import '../../../services/ad_service.dart';
import 'history_item_details_screen.dart';

class HistoryItemCard extends StatelessWidget {
  final QRHistoryItem item;
  final VoidCallback onDelete;
  final VoidCallback onShare;
  final VoidCallback onReuse;

  const HistoryItemCard({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onShare,
    required this.onReuse,
  });

  Color get _typeColor {
    final c = item.content;
    if (c.startsWith('http')) return kTypeUrl;
    if (c.startsWith('tel:')) return kTypePhone;
    if (c.startsWith('WIFI:')) return kTypeWifi;
    if (c.startsWith('BEGIN:VCARD')) return kTypeContact;
    return kTypeText;
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _typeColor;

    return GestureDetector(
      onTap: () => _showItemDetails(context),
      child: Container(
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kBorder, width: 1),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Type icon tile
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, size: 20, color: typeColor),
            ),
            const SizedBox(width: 14),
            // Title/preview/timestamp
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.displayTitle,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: kText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.displayDescription,
                    style: GoogleFonts.inter(fontSize: 13, color: kText2),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTimestamp(item.timestamp),
                    style: GoogleFonts.inter(fontSize: 11, color: kTextMuted),
                  ),
                ],
              ),
            ),
            // 3-dot menu
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'share':
                    onShare();
                    break;
                  case 'reuse':
                    onReuse();
                    break;
                  case 'delete':
                    onDelete();
                    break;
                }
              },
              color: kSurface2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: kBorder),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'share',
                  child: Text(
                    'Share',
                    style: GoogleFonts.inter(color: kText, fontSize: 14),
                  ),
                ),
                PopupMenuItem(
                  value: 'reuse',
                  child: Text(
                    'Reuse',
                    style: GoogleFonts.inter(color: kText, fontSize: 14),
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    'Delete',
                    style: GoogleFonts.inter(color: kRose, fontSize: 14),
                  ),
                ),
              ],
              child: Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                child: const Icon(Icons.more_vert, color: kTextMuted, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showItemDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HistoryItemDetailsScreen(
          item: item,
          onDelete: onDelete,
          onShare: onShare,
          onReuse: onReuse,
        ),
      ),
    ).then((_) => AdService.instance.recordAction());
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final itemDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (itemDate == today) {
      return 'Today at ${DateFormat('HH:mm').format(timestamp)}';
    } else if (itemDate == yesterday) {
      return 'Yesterday at ${DateFormat('HH:mm').format(timestamp)}';
    } else {
      return DateFormat('MMM dd, yyyy').format(timestamp);
    }
  }
}
