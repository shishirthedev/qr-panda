import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui' as ui;
import '../models/qr_generator_data.dart';

extension ColorExtension on Color {
  String toHex() {
    return '#${value.toRadixString(16).substring(2).toUpperCase()}';
  }
}

class QRCustomizationPanel extends StatefulWidget {
  final QRGeneratorData qrData;
  final ValueChanged<QRGeneratorData> onDataChanged;

  const QRCustomizationPanel({
    super.key,
    required this.qrData,
    required this.onDataChanged,
  });

  @override
  State<QRCustomizationPanel> createState() => _QRCustomizationPanelState();
}

class _QRCustomizationPanelState extends State<QRCustomizationPanel> {
  late QRGeneratorData _localData;

  @override
  void initState() {
    super.initState();
    _localData = widget.qrData;
  }

  @override
  void didUpdateWidget(QRCustomizationPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.qrData != widget.qrData) {
      _localData = widget.qrData;
    }
  }

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
              'Customization',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSizeSlider(),
            const SizedBox(height: 16),
            _buildColorPickers(),
            const SizedBox(height: 16),
            _buildLogoSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Size'),
            Text('${_localData.size.toInt()}px'),
          ],
        ),
        Slider(
          value: _localData.size,
          min: 100.0,
          max: 500.0,
          divisions: 40,
          label: '${_localData.size.toInt()}px',
          onChanged: (value) {
            setState(() {
              _localData = _localData.copyWith(size: value);
            });
            _notifyDataChanged();
          },
        ),
      ],
    );
  }

  Widget _buildColorPickers() {
    return Row(
      children: [
        Expanded(
          child: _buildColorPicker(
            label: 'Foreground',
            color: _localData.foregroundColor,
            onColorChanged: (color) {
              setState(() {
                _localData = _localData.copyWith(foregroundColor: color);
              });
              _notifyDataChanged();
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildColorPicker(
            label: 'Background',
            color: _localData.backgroundColor,
            onColorChanged: (color) {
              setState(() {
                _localData = _localData.copyWith(backgroundColor: color);
              });
              _notifyDataChanged();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorPicker({
    required String label,
    required Color color,
    required ValueChanged<Color> onColorChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showColorPicker(context, color, onColorChanged),
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Center(
              child: Text(
                '#${color.toHex()}',
                style: TextStyle(
                  color: _getContrastColor(color),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Logo (Optional)'),
            if (_localData.logoImage != null)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _removeLogo,
                tooltip: 'Remove Logo',
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_localData.logoImage != null)
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                color: Colors.grey[200],
                child: const Icon(
                  Icons.image,
                  size: 40,
                  color: Colors.grey,
                ),
              ),
            ),
          )
        else
          ElevatedButton.icon(
            onPressed: _pickLogo,
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('Add Logo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[100],
              foregroundColor: Colors.grey[700],
            ),
          ),
      ],
    );
  }

  void _showColorPicker(
    BuildContext context,
    Color initialColor,
    ValueChanged<Color> onColorChanged,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick Color'),
        content: SingleChildScrollView(
                  child: ColorPicker(
          pickerColor: initialColor,
          onColorChanged: onColorChanged,
        ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickLogo() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 200,
        maxHeight: 200,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        
        setState(() {
          _localData = _localData.copyWith(logoImage: frame.image);
        });
        _notifyDataChanged();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking logo: $e')),
      );
    }
  }

  void _removeLogo() {
    setState(() {
      _localData = _localData.copyWith(logoImage: null);
    });
    _notifyDataChanged();
  }

  void _notifyDataChanged() {
    widget.onDataChanged(_localData);
  }

  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

// Simple color picker widget
class ColorPicker extends StatefulWidget {
  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;

  const ColorPicker({
    super.key,
    required this.pickerColor,
    required this.onColorChanged,
  });

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late Color _currentColor;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.pickerColor;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildColorPalette(),
        const SizedBox(height: 16),
        _buildColorSlider(),
      ],
    );
  }

  Widget _buildColorPalette() {
    final colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
      Colors.black,
      Colors.white,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((color) {
        final isSelected = _currentColor == color;
        return GestureDetector(
          onTap: () {
            setState(() {
              _currentColor = color;
            });
            widget.onColorChanged(color);
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey[300]!,
                width: isSelected ? 3 : 1,
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildColorSlider() {
    return Column(
      children: [
        _buildSliderRow('Red', (_currentColor.r * 255.0).round(), (value) {
          setState(() {
            _currentColor = Color.fromARGB(
              (_currentColor.a * 255.0).round(),
              value.toInt(),
              (_currentColor.g * 255.0).round(),
              (_currentColor.b * 255.0).round(),
            );
          });
          widget.onColorChanged(_currentColor);
        }),
        _buildSliderRow('Green', (_currentColor.g * 255.0).round(), (value) {
          setState(() {
            _currentColor = Color.fromARGB(
              (_currentColor.a * 255.0).round(),
              (_currentColor.r * 255.0).round(),
              value.toInt(),
              (_currentColor.b * 255.0).round(),
            );
          });
          widget.onColorChanged(_currentColor);
        }),
        _buildSliderRow('Blue', (_currentColor.b * 255.0).round(), (value) {
          setState(() {
            _currentColor = Color.fromARGB(
              (_currentColor.a * 255.0).round(),
              (_currentColor.r * 255.0).round(),
              (_currentColor.g * 255.0).round(),
              value.toInt(),
            );
          });
          widget.onColorChanged(_currentColor);
        }),
      ],
    );
  }

  Widget _buildSliderRow(String label, int value, ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(label),
        ),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: 0,
            max: 255,
            divisions: 255,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 50,
          child: Text(value.toString()),
        ),
      ],
    );
  }
}
