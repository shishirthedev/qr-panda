import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../qr_scanner/qr_scanner.dart';
import '../qr_generator/qr_generator.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QuickQR'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Welcome to QuickQR',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildFeatureCard(
              context,
              icon: Icons.qr_code_scanner,
              title: 'QR Code Scanner',
              subtitle: 'Scan QR codes with your camera or from gallery images',
              onTap: () => _navigateToQRScanner(context),
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              icon: Icons.qr_code,
              title: 'QR Code Generator',
              subtitle: 'Create QR codes for URLs, text, contacts, and WiFi',
              onTap: () => _navigateToQRGenerator(context),
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              icon: Icons.history,
              title: 'Scan History',
              subtitle: 'View your previous QR code scans',
              onTap: () {
                // TODO: Implement scan history
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Scan History coming soon!')),
                );
              },
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToQRScanner(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => QRScannerBloc(),
          child: const QRScannerScreen(),
        ),
      ),
    );
  }

  void _navigateToQRGenerator(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QRGeneratorScreen(),
      ),
    );
  }
}
