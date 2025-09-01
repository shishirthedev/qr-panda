import 'package:flutter/material.dart';
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'QR Generator',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // QR Type Selector
            _buildQRTypeSelector(),
            const SizedBox(height: 24),
            
            // Input Form
            _buildInputForm(),
            const SizedBox(height: 24),
            
            // Generate Button
            _buildGenerateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildQRTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'QR Code Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
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
      ],
    );
  }

  Widget _buildInputForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Input Data',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        Form(
          key: _formKey,
          child: _buildTypeSpecificInputs(),
        ),
      ],
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
            color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
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
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
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
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
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



  Widget _buildGenerateButton() {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3B82F6),
            Color(0xFF1D4ED8),
          ],
        ),
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
          onTap: _isGenerating ? null : _generateAndShowResult,
          child: Center(
            child: _isGenerating
                ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Generating...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
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
                        size: 22,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Generate QR Code',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
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
    // First try to use original form data
    if (_qrData.originalType != null) {
      setState(() {
        _selectedType = _qrData.originalType!;
      });
      
      // Pre-fill form fields based on original type
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
      // Fallback: Try to parse QR content to determine type and extract data
      _parseQRContentToForm(_qrData.qrContent);
    }
  }

  void _parseQRContentToForm(String qrContent) {
    if (qrContent.isEmpty) return;

    // Try to determine QR type and extract data
    if (qrContent.startsWith('tel:')) {
      // Phone number
      setState(() {
        _selectedType = QRGeneratorType.phone;
      });
      _phoneController.text = qrContent.substring(4);
    } else if (qrContent.startsWith('WIFI:')) {
      // WiFi
      setState(() {
        _selectedType = QRGeneratorType.wifi;
      });
      _parseWifiContent(qrContent);
    } else if (qrContent.startsWith('BEGIN:VCARD')) {
      // Contact
      setState(() {
        _selectedType = QRGeneratorType.contact;
      });
      _parseContactContent(qrContent);
    } else if (qrContent.startsWith('http://') || qrContent.startsWith('https://')) {
      // URL
      setState(() {
        _selectedType = QRGeneratorType.url;
      });
      _urlController.text = qrContent;
    } else {
      // Text
      setState(() {
        _selectedType = QRGeneratorType.text;
      });
      _textController.text = qrContent;
    }
  }

  void _parseWifiContent(String wifiContent) {
    final parts = wifiContent.split(';');
    for (final part in parts) {
      if (part.startsWith('S:')) {
        _ssidController.text = part.substring(2);
      } else if (part.startsWith('P:')) {
        _passwordController.text = part.substring(2);
      }
    }
  }

  void _parseContactContent(String contactContent) {
    final lines = contactContent.split('\n');
    for (final line in lines) {
      if (line.startsWith('FN:')) {
        _nameController.text = line.substring(3);
      } else if (line.startsWith('TEL:')) {
        _phoneController.text = line.substring(4);
      } else if (line.startsWith('EMAIL:')) {
        _emailController.text = line.substring(6);
      }
    }
  }

  void _generateAndShowResult() {
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

      // Store original form data for reuse
      QRGeneratorData qrDataWithOriginal = _qrData.copyWith(
        qrContent: qrContent,
        originalType: _selectedType,
        originalText: _selectedType == QRGeneratorType.text ? _textController.text.trim() : null,
        originalUrl: _selectedType == QRGeneratorType.url ? _urlController.text.trim() : null,
        originalPhone: _selectedType == QRGeneratorType.phone ? _phoneController.text.trim() : null,
        originalSsid: _selectedType == QRGeneratorType.wifi ? _ssidController.text.trim() : null,
        originalPassword: _selectedType == QRGeneratorType.wifi ? _passwordController.text.trim() : null,
        originalName: _selectedType == QRGeneratorType.contact ? _nameController.text.trim() : null,
        originalEmail: _selectedType == QRGeneratorType.contact ? _emailController.text.trim() : null,
      );

      setState(() {
        _qrData = qrDataWithOriginal;
        _isGenerating = false;
      });

      // Navigate to result screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => QRResultScreen(
            qrData: _qrData,
            qrContent: qrContent,
          ),
        ),
      );
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


}
