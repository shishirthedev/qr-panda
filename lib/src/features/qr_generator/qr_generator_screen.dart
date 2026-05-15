import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_theme.dart';
import 'models/qr_generator_data.dart';
import 'widgets/qr_type_selector.dart';
import 'widgets/qr_result_screen.dart';

class QRGeneratorScreen extends StatefulWidget {
  final QRGeneratorData? initialData;

  const QRGeneratorScreen({super.key, this.initialData});

  @override
  State<QRGeneratorScreen> createState() => _QRGeneratorScreenState();
}

class _QRGeneratorScreenState extends State<QRGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _urlController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ssidController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  QRGeneratorType _selectedType = QRGeneratorType.text;
  QRGeneratorData _qrData = QRGeneratorData();
  bool _isGenerating = false;

  // WiFi security: 0=None, 1=WPA, 2=WEP
  int _wifiSecurityIndex = 1;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _qrData = widget.initialData!;
      _prefillFormFromData();
    } else {
      _qrData = QRGeneratorData.defaultValues();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _urlController.dispose();
    _phoneController.dispose();
    _ssidController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
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
                    'Create QR',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: kText,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // QR Type Selector
                    _sectionLabel('QR CODE TYPE'),
                    const SizedBox(height: 12),
                    QRTypeSelector(
                      selectedType: _selectedType,
                      onTypeChanged: (type) {
                        setState(() {
                          _selectedType = type;
                          _clearForm();
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Input form
                    _sectionLabel('INPUT DATA'),
                    const SizedBox(height: 12),
                    Form(
                      key: _formKey,
                      child: _buildTypeSpecificInputs(),
                    ),
                    const SizedBox(height: 24),

                    // Customize section
                    _sectionLabel('CUSTOMIZE'),
                    const SizedBox(height: 12),
                    _buildColorSection(),
                    const SizedBox(height: 28),

                    // Generate button
                    _buildGenerateButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.8,
        color: kTextMuted,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    required Color typeColor,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(color: kText2, fontSize: 14),
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: kTextMuted, fontSize: 14),
      filled: true,
      fillColor: kSurface,
      prefixIcon: Container(
        margin: const EdgeInsets.all(12),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: typeColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: typeColor, size: 20),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kBorder, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kRose, width: 1),
      ),
      contentPadding: const EdgeInsets.all(16),
    );
  }

  Widget _buildTypeSpecificInputs() {
    switch (_selectedType) {
      case QRGeneratorType.text:
        return TextFormField(
          controller: _textController,
          style: GoogleFonts.inter(color: kText, fontSize: 14),
          decoration: _inputDecoration(
            label: 'Text Content',
            hint: 'Enter text to encode',
            icon: Icons.text_fields,
            typeColor: kTypeText,
          ),
          maxLines: 3,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Please enter some text' : null,
        );

      case QRGeneratorType.url:
        return TextFormField(
          controller: _urlController,
          style: GoogleFonts.inter(color: kText, fontSize: 14),
          decoration: _inputDecoration(
            label: 'URL',
            hint: 'https://example.com',
            icon: Icons.link,
            typeColor: kTypeUrl,
          ),
          keyboardType: TextInputType.url,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Please enter a URL';
            final uri = Uri.tryParse(v);
            if (uri == null || !uri.hasScheme) return 'Please enter a valid URL';
            return null;
          },
        );

      case QRGeneratorType.phone:
        return TextFormField(
          controller: _phoneController,
          style: GoogleFonts.inter(color: kText, fontSize: 14),
          decoration: _inputDecoration(
            label: 'Phone Number',
            hint: '+1234567890',
            icon: Icons.phone,
            typeColor: kTypePhone,
          ),
          keyboardType: TextInputType.phone,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Please enter a phone number' : null,
        );

      case QRGeneratorType.wifi:
        return _buildWifiInput();

      case QRGeneratorType.contact:
        return _buildContactInput();
    }
  }

  Widget _buildWifiInput() {
    return Column(
      children: [
        TextFormField(
          controller: _ssidController,
          style: GoogleFonts.inter(color: kText, fontSize: 14),
          decoration: _inputDecoration(
            label: 'WiFi Network Name (SSID)',
            hint: 'MyWiFi',
            icon: Icons.wifi,
            typeColor: kTypeWifi,
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Please enter WiFi name' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          style: GoogleFonts.inter(color: kText, fontSize: 14),
          decoration: _inputDecoration(
            label: 'Password (Optional)',
            hint: 'Leave empty for open networks',
            icon: Icons.lock_outline,
            typeColor: kTypeWifi,
          ),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        // Segmented security type
        _buildWifiSecuritySelector(),
      ],
    );
  }

  Widget _buildWifiSecuritySelector() {
    const labels = ['None', 'WPA', 'WEP'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Security Type',
          style: GoogleFonts.inter(fontSize: 13, color: kText2),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(labels.length, (i) {
            final isSelected = _wifiSecurityIndex == i;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _wifiSecurityIndex = i;
                    _qrData = _qrData.copyWith(
                      wifiSecurityType: i == 0 ? 'nopass' : labels[i],
                    );
                  });
                },
                child: Container(
                  height: 44,
                  margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                  decoration: BoxDecoration(
                    color: isSelected ? kPrimary : kSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected
                        ? null
                        : Border.all(color: kBorder, width: 1),
                  ),
                  child: Center(
                    child: Text(
                      labels[i],
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : kText2,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildContactInput() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          style: GoogleFonts.inter(color: kText, fontSize: 14),
          decoration: _inputDecoration(
            label: 'Full Name',
            hint: 'John Doe',
            icon: Icons.person,
            typeColor: kTypeContact,
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Please enter a name' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          style: GoogleFonts.inter(color: kText, fontSize: 14),
          decoration: _inputDecoration(
            label: 'Phone Number',
            hint: '+1234567890',
            icon: Icons.phone,
            typeColor: kTypeContact,
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          style: GoogleFonts.inter(color: kText, fontSize: 14),
          decoration: _inputDecoration(
            label: 'Email (Optional)',
            hint: 'john@example.com',
            icon: Icons.email,
            typeColor: kTypeContact,
          ),
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  Widget _buildColorSection() {
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder, width: 1),
      ),
      child: Column(
        children: [
          _buildColorRow(
            label: 'QR Color',
            color: _qrData.foregroundColor,
            onTap: () => _showColorPickerSheet(
              title: 'QR Color',
              initialColor: _qrData.foregroundColor,
              onColorChanged: (c) {
                setState(() {
                  _qrData = _qrData.copyWith(foregroundColor: c);
                });
              },
            ),
          ),
          Divider(height: 1, color: kBorder),
          _buildColorRow(
            label: 'Background Color',
            color: _qrData.backgroundColor,
            onTap: () => _showColorPickerSheet(
              title: 'Background Color',
              initialColor: _qrData.backgroundColor,
              onColorChanged: (c) {
                setState(() {
                  _qrData = _qrData.copyWith(backgroundColor: c);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorRow({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final hex = color.toARGB32().toRadixString(16).toUpperCase().padLeft(8, '0').substring(2);
    final hexString = '#$hex';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 14, color: kText),
            ),
            const Spacer(),
            Text(
              hexString,
              style: GoogleFonts.sourceCodePro(
                fontSize: 11,
                color: kTextMuted,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: kBorder, width: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPickerSheet({
    required String title,
    required Color initialColor,
    required ValueChanged<Color> onColorChanged,
  }) {
    // Simple color preset picker in a bottom sheet
    final presets = [
      Colors.black,
      Colors.white,
      kPrimary,
      kGreen,
      kAmber,
      kRose,
      kTypeUrl,
      kTypePhone,
      kTypeWifi,
      kTypeContact,
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: kSurface2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: kBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: kText,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: presets.map((c) {
                final isSelected = c.toARGB32() == initialColor.toARGB32();
                return GestureDetector(
                  onTap: () {
                    onColorChanged(c);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? kPrimary : kBorder,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    return GestureDetector(
      onTap: _isGenerating ? null : _generateAndShowResult,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment(-1, -1),
            end: Alignment(1, 1),
            colors: [kPrimaryDark, kPrimary, kPrimaryLight],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: kPrimaryGlow,
              blurRadius: 28,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: _isGenerating
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.qr_code, color: Colors.white, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      'Generate QR Code',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _clearForm() {
    _textController.clear();
    _urlController.clear();
    _phoneController.clear();
    _ssidController.clear();
    _passwordController.clear();
    _nameController.clear();
    _emailController.clear();
    setState(() {
      _qrData = _qrData.copyWith(qrContent: '');
    });
  }

  void _prefillFormFromData() {
    if (_qrData.originalType != null) {
      setState(() {
        _selectedType = _qrData.originalType!;
      });

      switch (_qrData.originalType!) {
        case QRGeneratorType.text:
          if (_qrData.originalText != null) {
            _textController.text = _qrData.originalText!;
          }
          break;
        case QRGeneratorType.url:
          if (_qrData.originalUrl != null) {
            _urlController.text = _qrData.originalUrl!;
          }
          break;
        case QRGeneratorType.phone:
          if (_qrData.originalPhone != null) {
            _phoneController.text = _qrData.originalPhone!;
          }
          break;
        case QRGeneratorType.wifi:
          if (_qrData.originalSsid != null) {
            _ssidController.text = _qrData.originalSsid!;
          }
          if (_qrData.originalPassword != null) {
            _passwordController.text = _qrData.originalPassword!;
          }
          break;
        case QRGeneratorType.contact:
          if (_qrData.originalName != null) {
            _nameController.text = _qrData.originalName!;
          }
          if (_qrData.originalPhone != null) {
            _phoneController.text = _qrData.originalPhone!;
          }
          if (_qrData.originalEmail != null) {
            _emailController.text = _qrData.originalEmail!;
          }
          break;
      }
    } else {
      _parseQRContentToForm(_qrData.qrContent);
    }
  }

  void _parseQRContentToForm(String qrContent) {
    if (qrContent.isEmpty) return;

    if (qrContent.startsWith('tel:')) {
      setState(() => _selectedType = QRGeneratorType.phone);
      _phoneController.text = qrContent.substring(4);
    } else if (qrContent.startsWith('WIFI:')) {
      setState(() => _selectedType = QRGeneratorType.wifi);
      _parseWifiContent(qrContent);
    } else if (qrContent.startsWith('BEGIN:VCARD')) {
      setState(() => _selectedType = QRGeneratorType.contact);
      _parseContactContent(qrContent);
    } else if (qrContent.startsWith('http://') ||
        qrContent.startsWith('https://')) {
      setState(() => _selectedType = QRGeneratorType.url);
      _urlController.text = qrContent;
    } else {
      setState(() => _selectedType = QRGeneratorType.text);
      _textController.text = qrContent;
    }
  }

  void _parseWifiContent(String wifiContent) {
    final parts = wifiContent.split(';');
    for (final part in parts) {
      if (part.startsWith('S:')) _ssidController.text = part.substring(2);
      if (part.startsWith('P:')) _passwordController.text = part.substring(2);
    }
  }

  void _parseContactContent(String contactContent) {
    final lines = contactContent.split('\n');
    for (final line in lines) {
      if (line.startsWith('FN:')) _nameController.text = line.substring(3);
      if (line.startsWith('TEL:')) _phoneController.text = line.substring(4);
      if (line.startsWith('EMAIL:')) _emailController.text = line.substring(6);
    }
  }

  void _generateAndShowResult() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isGenerating = true);

    try {
      String qrContent = '';

      switch (_selectedType) {
        case QRGeneratorType.text:
          qrContent = _textController.text.trim();
          break;
        case QRGeneratorType.url:
          qrContent = _urlController.text.trim();
          break;
        case QRGeneratorType.phone:
          qrContent = 'tel:${_phoneController.text.trim()}';
          break;
        case QRGeneratorType.wifi:
          qrContent = _buildWifiQRString();
          break;
        case QRGeneratorType.contact:
          qrContent = _buildContactQRString();
          break;
      }

      final qrDataWithOriginal = _qrData.copyWith(
        qrContent: qrContent,
        originalType: _selectedType,
        originalText:
            _selectedType == QRGeneratorType.text ? _textController.text.trim() : null,
        originalUrl:
            _selectedType == QRGeneratorType.url ? _urlController.text.trim() : null,
        originalPhone:
            _selectedType == QRGeneratorType.phone ? _phoneController.text.trim() : null,
        originalSsid:
            _selectedType == QRGeneratorType.wifi ? _ssidController.text.trim() : null,
        originalPassword:
            _selectedType == QRGeneratorType.wifi ? _passwordController.text.trim() : null,
        originalName:
            _selectedType == QRGeneratorType.contact ? _nameController.text.trim() : null,
        originalEmail:
            _selectedType == QRGeneratorType.contact ? _emailController.text.trim() : null,
      );

      setState(() {
        _qrData = qrDataWithOriginal;
        _isGenerating = false;
      });

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => QRResultScreen(
            qrData: _qrData,
            qrContent: qrContent,
          ),
        ),
      );
    } catch (e) {
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating QR code: $e')),
      );
    }
  }

  String _buildWifiQRString() {
    final ssid = _ssidController.text.trim();
    final password = _passwordController.text.trim();
    const securityLabels = ['nopass', 'WPA', 'WEP'];
    final security = securityLabels[_wifiSecurityIndex];
    return 'WIFI:S:$ssid;T:$security;P:$password;;';
  }

  String _buildContactQRString() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();

    final vCard = StringBuffer();
    vCard.writeln('BEGIN:VCARD');
    vCard.writeln('VERSION:3.0');
    vCard.writeln('FN:$name');
    if (phone.isNotEmpty) vCard.writeln('TEL:$phone');
    if (email.isNotEmpty) vCard.writeln('EMAIL:$email');
    vCard.writeln('END:VCARD');

    return vCard.toString();
  }
}
