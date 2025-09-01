import 'package:flutter/material.dart';
import '../models/qr_generator_data.dart';

class QRTypeSelector extends StatelessWidget {
  final QRGeneratorType selectedType;
  final ValueChanged<QRGeneratorType> onTypeChanged;

  const QRTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.category,
                    color: Color(0xFF8B5CF6),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'QR Code Type',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: QRGeneratorType.values.map((type) {
                return _buildTypeChip(context, type);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(BuildContext context, QRGeneratorType type) {
    final isSelected = selectedType == type;
    final typeInfo = _getTypeInfo(type);

    return GestureDetector(
      onTap: () => onTypeChanged(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
                     color: isSelected ? typeInfo.color : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? typeInfo.color : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
                         boxShadow: isSelected
                   ? [
                       BoxShadow(
                         color: typeInfo.color.withValues(alpha: 0.3),
                         blurRadius: 12,
                         offset: const Offset(0, 4),
                       ),
                     ]
                   : [
                       BoxShadow(
                         color: Colors.black.withValues(alpha: 0.05),
                         blurRadius: 8,
                         offset: const Offset(0, 2),
                       ),
                     ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                                 color: isSelected
                     ? Colors.white.withValues(alpha: 0.2)
                     : typeInfo.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                typeInfo.icon,
                color: isSelected ? Colors.white : typeInfo.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              typeInfo.label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF374151),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  TypeInfo _getTypeInfo(QRGeneratorType type) {
    switch (type) {
      case QRGeneratorType.text:
        return TypeInfo(
          label: 'Text',
          icon: Icons.text_fields,
          color: const Color(0xFF3B82F6),
        );
      case QRGeneratorType.url:
        return TypeInfo(
          label: 'URL',
          icon: Icons.link,
          color: const Color(0xFF10B981),
        );
      case QRGeneratorType.phone:
        return TypeInfo(
          label: 'Phone',
          icon: Icons.phone,
          color: const Color(0xFFF59E0B),
        );
      case QRGeneratorType.wifi:
        return TypeInfo(
          label: 'WiFi',
          icon: Icons.wifi,
          color: const Color(0xFF8B5CF6),
        );
      case QRGeneratorType.contact:
        return TypeInfo(
          label: 'Contact',
          icon: Icons.person,
          color: const Color(0xFF14B8A6),
        );
    }
  }
}

class TypeInfo {
  final String label;
  final IconData icon;
  final Color color;

  const TypeInfo({
    required this.label,
    required this.icon,
    required this.color,
  });
}
