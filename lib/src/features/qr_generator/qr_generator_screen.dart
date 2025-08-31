import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'models/qr_generator_data.dart';
import 'widgets/qr_type_selector.dart';
import 'widgets/qr_customization_panel.dart';

class QRGeneratorScreen extends StatefulWidget {
  const QRGeneratorScreen({super.key});

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
  
  QRGeneratorType _selectedType = QRGeneratorType.text;
  QRGeneratorData _qrData = QRGeneratorData();
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _qrData = QRGeneratorData.defaultValues();
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
      appBar: AppBar(
        title: const Text('QR Code Generator'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_qrData.qrContent.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveQRCode,
              tooltip: 'Save QR Code',
            ),
          if (_qrData.qrContent.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareQRCode,
              tooltip: 'Share QR Code',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildQRTypeSelector(),
            const SizedBox(height: 24),
            _buildInputForm(),
            const SizedBox(height: 24),
            _buildCustomizationPanel(),
            const SizedBox(height: 24),
            _buildGenerateButton(),
            const SizedBox(height: 24),
            if (_qrData.qrContent.isNotEmpty) _buildQRCodeDisplay(),
          ],
        ),
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
    return Form(
      key: _formKey,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Input Data',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
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
      decoration: const InputDecoration(
        labelText: 'Text Content',
        hintText: 'Enter text to encode in QR code',
        border: OutlineInputBorder(),
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
      decoration: const InputDecoration(
        labelText: 'URL',
        hintText: 'https://example.com',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.link),
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
      decoration: const InputDecoration(
        labelText: 'Phone Number',
        hintText: '+1234567890',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.phone),
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
          decoration: const InputDecoration(
            labelText: 'WiFi Network Name (SSID)',
            hintText: 'MyWiFi',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.wifi),
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
          decoration: const InputDecoration(
            labelText: 'Password (Optional)',
            hintText: 'Leave empty for open networks',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.lock),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Security Type',
            border: OutlineInputBorder(),
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
          decoration: const InputDecoration(
            labelText: 'Full Name',
            hintText: 'John Doe',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
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
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            hintText: '+1234567890',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email (Optional)',
            hintText: 'john@example.com',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
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
    return ElevatedButton.icon(
      onPressed: _isGenerating ? null : _generateQRCode,
      icon: _isGenerating 
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.qr_code),
      label: Text(_isGenerating ? 'Generating...' : 'Generate QR Code'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        textStyle: const TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildQRCodeDisplay() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Generated QR Code',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            RepaintBoundary(
              key: _qrKey,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveQRCode,
                    icon: const Icon(Icons.save),
                    label: const Text('Save'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _shareQRCode,
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
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
        SnackBar(content: Text('Error generating QR code: $e')),
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
      // For now, we'll just show a success message since we can't save to gallery
      // without the problematic image_gallery_saver package
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR Code ready! You can now share it.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing QR code: $e')),
      );
    }
  }
}
