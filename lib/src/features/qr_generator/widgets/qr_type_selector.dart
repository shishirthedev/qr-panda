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
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: QRGeneratorType.values.map((type) {
        return _buildTypeChip(context, type);
      }).toList(),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? typeInfo.color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? typeInfo.color : Colors.grey[300]!,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: typeInfo.color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              typeInfo.icon,
              color: isSelected ? Colors.white : typeInfo.color,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              typeInfo.label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF374151),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
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
