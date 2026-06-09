import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Demo Modul 8 - Assets & Media
///
/// Menampilkan:
/// 1. Gambar dari assets (AssetImage)
/// 2. Gambar dari network (CachedNetworkImage)
/// 3. Data JSON dari assets
class AssetsDemoScreen extends StatefulWidget {
  const AssetsDemoScreen({super.key});

  @override
  State<AssetsDemoScreen> createState() => _AssetsDemoScreenState();
}

class _AssetsDemoScreenState extends State<AssetsDemoScreen> {
  Map<String, dynamic>? _jsonData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJsonData();
  }

  /// Load JSON dari assets
  Future<void> _loadJsonData() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/config.json');
      final data = json.decode(jsonString) as Map<String, dynamic>;
      setState(() {
        _jsonData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modul 8 - Assets & Media'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar 1 - Dari Assets
            buildSectionTitle('Gambar 1 (Dari Assets)'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/logo/logoipsum-411.png',
                        width: 200,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 200,
                            height: 150,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.error, size: 40),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Logo diload dari assets menggunakan Image.asset()',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Gambar 2 - Dari Network
            buildSectionTitle('Gambar 2 (Dari Network)'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: 'https://picsum.photos/400/300',
                        width: 200,
                        height: 150,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 200,
                          height: 150,
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 200,
                          height: 150,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.error, size: 40),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Gambar diload dari network menggunakan CachedNetworkImage',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Data JSON
            buildSectionTitle('Data JSON (Dari Assets)'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : _jsonData != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDataRow('App Name', _jsonData!['app_name']?.toString() ?? 'N/A'),
                              _buildDataRow('Version', _jsonData!['version']?.toString() ?? 'N/A'),
                              const Divider(height: 24),
                              if (_jsonData!['features'] != null) ...[
                                const Text(
                                  'Features:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                _buildFeatureItem('Ticket Management', _jsonData!['features']?['ticket_management'] == true),
                                _buildFeatureItem('User Authentication', _jsonData!['features']?['user_authentication'] == true),
                                _buildFeatureItem('Notifications', _jsonData!['features']?['notifications'] == true),
                                _buildFeatureItem('File Upload', _jsonData!['features']?['file_upload'] == true),
                              ],
                              const Divider(height: 24),
                              if (_jsonData!['support'] != null) ...[
                                const Text(
                                  'Support:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                _buildDataRow('Email', _jsonData!['support']?['email']?.toString() ?? 'N/A'),
                                _buildDataRow('Phone', _jsonData!['support']?['phone']?.toString() ?? 'N/A'),
                              ],
                            ],
                          )
                        : const Text('Gagal memuat data JSON'),
              ),
            ),

            const SizedBox(height: 24),

            // Info tambahan
            Card(
              color: Colors.blue.shade50,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Info',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Gambar dari assets: Image.asset() atau AssetImage()\n'
                      '• Gambar dari network: CachedNetworkImage()\n'
                      '• Data JSON: rootBundle.loadString()',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String label, bool isEnabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isEnabled ? Icons.check_circle : Icons.cancel,
            color: isEnabled ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
