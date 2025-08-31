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
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'QR Code Type',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
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

    return FilterChip(
      selected: isSelected,
      onSelected: (_) => onTypeChanged(type),
      avatar: Icon(
        typeInfo.icon,
        color: isSelected ? Colors.white : typeInfo.color,
        size: 20,
      ),
      label: Text(
        typeInfo.label,
        style: TextStyle(
          color: isSelected ? Colors.white : null,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      backgroundColor: Colors.grey[100],
      selectedColor: typeInfo.color,
      checkmarkColor: Colors.white,
      elevation: isSelected ? 4 : 1,
      pressElevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  TypeInfo _getTypeInfo(QRGeneratorType type) {
    switch (type) {
      case QRGeneratorType.text:
        return TypeInfo(
          label: 'Text',
          icon: Icons.text_fields,
          color: Colors.blue,
        );
      case QRGeneratorType.url:
        return TypeInfo(
          label: 'URL',
          icon: Icons.link,
          color: Colors.green,
        );
      case QRGeneratorType.phone:
        return TypeInfo(
          label: 'Phone',
          icon: Icons.phone,
          color: Colors.orange,
        );
      case QRGeneratorType.wifi:
        return TypeInfo(
          label: 'WiFi',
          icon: Icons.wifi,
          color: Colors.purple,
        );
      case QRGeneratorType.contact:
        return TypeInfo(
          label: 'Contact',
          icon: Icons.person,
          color: Colors.teal,
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
