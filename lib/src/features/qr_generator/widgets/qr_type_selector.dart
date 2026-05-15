import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/app_theme.dart';
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: QRGeneratorType.values.map((type) {
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: _buildChip(type),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChip(QRGeneratorType type) {
    final isSelected = selectedType == type;
    final info = _getTypeInfo(type);

    return GestureDetector(
      onTap: () => onTypeChanged(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 70,
        height: 64,
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [kPrimaryDark, kPrimary],
                )
              : null,
          color: isSelected ? null : kSurface,
          borderRadius: BorderRadius.circular(14),
          border: isSelected ? null : Border.all(color: kBorder, width: 1),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                      color: kPrimaryGlow,
                      blurRadius: 14,
                      offset: Offset(0, 4))
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              info.icon,
              size: 22,
              color: isSelected ? Colors.white : kText2,
            ),
            const SizedBox(height: 6),
            Text(
              info.label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : kText2,
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
        return TypeInfo(label: 'Text', icon: Icons.text_fields);
      case QRGeneratorType.url:
        return TypeInfo(label: 'URL', icon: Icons.link);
      case QRGeneratorType.phone:
        return TypeInfo(label: 'Phone', icon: Icons.phone);
      case QRGeneratorType.wifi:
        return TypeInfo(label: 'WiFi', icon: Icons.wifi);
      case QRGeneratorType.contact:
        return TypeInfo(label: 'Contact', icon: Icons.person);
    }
  }
}

class TypeInfo {
  final String label;
  final IconData icon;

  const TypeInfo({required this.label, required this.icon});
}
