import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/qr_history_item.dart';
import '../../services/qr_history_service.dart';
import 'models/qr_generator_data.dart';
import 'widgets/qr_type_selector.dart';
import 'widgets/qr_customization_panel.dart';

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
  
  final _qrKey = GlobalKey();
  final QRHistoryService _historyService = QRHistoryService();
  
  QRGeneratorType _selectedType = QRGeneratorType.text;
  QRGeneratorData _qrData = QRGeneratorData();
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _qrData = widget.initialData!;
      _qrData = _qrData.copyWith(qrContent: ''); // Clear content for reuse
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'QR Code Generator',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_qrData.qrContent.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.save, color: Color(0xFF10B981)),
              onPressed: _saveQRCode,
              tooltip: 'Save QR Code',
              ),
            ),
          if (_qrData.qrContent.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.share, color: Color(0xFF3B82F6)),
              onPressed: _shareQRCode,
              tooltip: 'Share QR Code',
              ),
            ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
                  // Header Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF667EEA),
                          const Color(0xFF764BA2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                                             boxShadow: [
                         BoxShadow(
                           color: const Color(0xFF667EEA).withValues(alpha: 0.3),
                           blurRadius: 20,
                           offset: const Offset(0, 10),
                         ),
                       ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                                                         Container(
                               padding: const EdgeInsets.all(12),
                               decoration: BoxDecoration(
                                 color: Colors.white.withValues(alpha: 0.2),
                                 borderRadius: BorderRadius.circular(12),
                               ),
                              child: const Icon(
                                Icons.qr_code,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Create QR Code',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Generate custom QR codes for any purpose',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // QR Type Selector
            _buildQRTypeSelector(),
            const SizedBox(height: 24),
                  
                  // Input Form
            _buildInputForm(),
            const SizedBox(height: 24),
                  
                  // Customization Panel
            _buildCustomizationPanel(),
            const SizedBox(height: 24),
                  
                  // Generate Button
            _buildGenerateButton(),
            const SizedBox(height: 24),
                  
                  // QR Code Display
            if (_qrData.qrContent.isNotEmpty) _buildQRCodeDisplay(),
          ],
        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRTypeSelector() {
    return QRTypeSelector(
      selectedType: _selectedType,
      onTypeChanged: (type) {
        setState(() {
          _selectedType = type;
          _clearForm();
        });
      },
    );
  }

  Widget _buildInputForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
      key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                                     Container(
                     padding: const EdgeInsets.all(8),
                     decoration: BoxDecoration(
                       color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                       borderRadius: BorderRadius.circular(8),
                     ),
                    child: const Icon(
                      Icons.edit_note,
                      color: Color(0xFF3B82F6),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                'Input Data',
                    style: TextStyle(
                      fontSize: 18,
                  fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                ),
              ),
                ],
              ),
              const SizedBox(height: 20),
              _buildTypeSpecificInputs(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSpecificInputs() {
    switch (_selectedType) {
      case QRGeneratorType.text:
        return _buildTextInput();
      case QRGeneratorType.url:
        return _buildUrlInput();
      case QRGeneratorType.phone:
        return _buildPhoneInput();
      case QRGeneratorType.wifi:
        return _buildWifiInput();
      case QRGeneratorType.contact:
        return _buildContactInput();
    }
  }

  Widget _buildTextInput() {
    return TextFormField(
      controller: _textController,
      decoration: InputDecoration(
        labelText: 'Text Content',
        hintText: 'Enter text to encode in QR code',
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
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.all(16),
      ),
      maxLines: 3,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );
  }

  Widget _buildUrlInput() {
    return TextFormField(
      controller: _urlController,
      decoration: InputDecoration(
        labelText: 'URL',
        hintText: 'https://example.com',
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
          borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.link, color: Color(0xFF10B981)),
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.all(16),
      ),
      keyboardType: TextInputType.url,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a URL';
        }
        final uri = Uri.tryParse(value);
        if (uri == null || !uri.hasScheme) {
          return 'Please enter a valid URL';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneInput() {
    return TextFormField(
      controller: _phoneController,
      decoration: InputDecoration(
        labelText: 'Phone Number',
        hintText: '+1234567890',
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
          borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 2),
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.phone, color: Color(0xFFF59E0B)),
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.all(16),
      ),
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a phone number';
        }
        return null;
      },
    );
  }

  Widget _buildWifiInput() {
    return Column(
      children: [
        TextFormField(
          controller: _ssidController,
          decoration: InputDecoration(
            labelText: 'WiFi Network Name (SSID)',
            hintText: 'MyWiFi',
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
              borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.wifi, color: Color(0xFF8B5CF6)),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.all(16),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter WiFi network name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Password (Optional)',
            hintText: 'Leave empty for open networks',
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
              borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.lock, color: Color(0xFF8B5CF6)),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.all(16),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Security Type',
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
              borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.all(16),
          ),
          value: _qrData.wifiSecurityType,
          items: const [
            DropdownMenuItem(value: 'WPA', child: Text('WPA/WPA2/WPA3')),
            DropdownMenuItem(value: 'WEP', child: Text('WEP')),
            DropdownMenuItem(value: 'nopass', child: Text('No Password')),
          ],
          onChanged: (value) {
            setState(() {
              _qrData = _qrData.copyWith(wifiSecurityType: value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildContactInput() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Full Name',
            hintText: 'John Doe',
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
              borderSide: const BorderSide(color: Color(0xFF14B8A6), width: 2),
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF14B8A6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.person, color: Color(0xFF14B8A6)),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.all(16),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            hintText: '+1234567890',
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
              borderSide: const BorderSide(color: Color(0xFF14B8A6), width: 2),
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF14B8A6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.phone, color: Color(0xFF14B8A6)),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.all(16),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email (Optional)',
            hintText: 'john@example.com',
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
              borderSide: const BorderSide(color: Color(0xFF14B8A6), width: 2),
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF14B8A6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.email, color: Color(0xFF14B8A6)),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.all(16),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  Widget _buildCustomizationPanel() {
    return QRCustomizationPanel(
      qrData: _qrData,
      onDataChanged: (data) {
        setState(() {
          _qrData = data;
        });
      },
    );
  }

  Widget _buildGenerateButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF667EEA),
            const Color(0xFF764BA2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
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
          borderRadius: BorderRadius.circular(16),
          onTap: _isGenerating ? null : _generateQRCode,
          child: Center(
            child: _isGenerating
                ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
              width: 20,
              height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Generating...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.qr_code,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Generate QR Code',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildQRCodeDisplay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                                   Container(
                     padding: const EdgeInsets.all(8),
                     decoration: BoxDecoration(
                       color: const Color(0xFF10B981).withValues(alpha: 0.1),
                       borderRadius: BorderRadius.circular(8),
                     ),
                  child: const Icon(
                    Icons.qr_code_2,
                    color: Color(0xFF10B981),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
              'Generated QR Code',
                  style: TextStyle(
                    fontSize: 18,
                fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
              ),
            ),
              ],
            ),
            const SizedBox(height: 20),
            RepaintBoundary(
              key: _qrKey,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                                     boxShadow: [
                     BoxShadow(
                       color: Colors.black.withValues(alpha: 0.05),
                       blurRadius: 10,
                       offset: const Offset(0, 2),
                     ),
                   ],
                ),
                child: QrImageView(
                  data: _qrData.qrContent,
                  version: QrVersions.auto,
                  size: _qrData.size,
                  backgroundColor: _qrData.backgroundColor,
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: _qrData.foregroundColor,
                  ),
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: _qrData.foregroundColor,
                  ),
                  embeddedImage: null, // Logo embedding temporarily disabled
                  embeddedImageStyle: _qrData.logoImage != null
                      ? QrEmbeddedImageStyle(
                          size: Size(_qrData.size * 0.2, _qrData.size * 0.2),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(12),
                                             boxShadow: [
                         BoxShadow(
                           color: const Color(0xFF10B981).withValues(alpha: 0.3),
                           blurRadius: 10,
                           offset: const Offset(0, 4),
                         ),
                       ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _saveQRCode,
                        child: const Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.save,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Save',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      borderRadius: BorderRadius.circular(12),
                                             boxShadow: [
                         BoxShadow(
                           color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                           blurRadius: 10,
                           offset: const Offset(0, 4),
                         ),
                       ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _shareQRCode,
                        child: const Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.share,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Share',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
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

  void _generateQRCode() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isGenerating = true;
    });

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

      setState(() {
        _qrData = _qrData.copyWith(qrContent: qrContent);
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating QR code: $e'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  String _buildWifiQRString() {
    final ssid = _ssidController.text.trim();
    final password = _passwordController.text.trim();
    final security = _qrData.wifiSecurityType;
    
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

  Future<void> _saveQRCode() async {
    try {
      // Save to history
      final historyItem = QRHistoryItem.fromGenerated(
        content: _qrData.qrContent,
        qrData: _qrData,
        title: _getQRCodeTitle(),
        description: _getQRCodeDescription(),
      );
      
      await _historyService.insertQRHistory(historyItem);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('QR Code saved to history!'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving QR code: $e'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  String _getQRCodeTitle() {
    switch (_selectedType) {
      case QRGeneratorType.text:
        return 'Text QR Code';
      case QRGeneratorType.url:
        return 'URL QR Code';
      case QRGeneratorType.phone:
        return 'Phone QR Code';
      case QRGeneratorType.wifi:
        return 'WiFi QR Code';
      case QRGeneratorType.contact:
        return 'Contact QR Code';
    }
  }

  String _getQRCodeDescription() {
    switch (_selectedType) {
      case QRGeneratorType.text:
        return _textController.text.trim();
      case QRGeneratorType.url:
        return _urlController.text.trim();
      case QRGeneratorType.phone:
        return _phoneController.text.trim();
      case QRGeneratorType.wifi:
        return 'WiFi: ${_ssidController.text.trim()}';
      case QRGeneratorType.contact:
        return 'Contact: ${_nameController.text.trim()}';
    }
  }

  Future<void> _shareQRCode() async {
    try {
      // Share the QR code content as text for now
      await Share.share(
        'QR Code Content: ${_qrData.qrContent}',
        subject: 'QR Code',
      );
    } catch (e) {
      if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing QR code: $e'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }
}
