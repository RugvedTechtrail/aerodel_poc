import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrPage extends StatelessWidget {
  const QrPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code API Scanner'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://api.qrserver.com/v1/create-qr-code/?size=100x100&data=QRCodeDemo',
              width: 100,
              height: 100,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.qr_code, size: 100),
            ),
            const SizedBox(height: 40),
            const Text(
              'Scan or Generate QR Codes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Generate QR codes from API URLs or scan QR codes to fetch data',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 50),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QRGeneratorPage(),
                  ),
                );
              },
              icon: const Icon(Icons.qr_code),
              label: const Text('Generate QR Code',
                  style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QRScannerPage(),
                  ),
                );
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan QR Code', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

class QRGeneratorPage extends StatefulWidget {
  const QRGeneratorPage({Key? key}) : super(key: key);

  @override
  State<QRGeneratorPage> createState() => _QRGeneratorPageState();
}

class _QRGeneratorPageState extends State<QRGeneratorPage> {
  final TextEditingController _apiUrlController =
      TextEditingController(text: 'https://jsonplaceholder.typicode.com/posts');
  final TextEditingController _idController = TextEditingController();
  String qrData = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _apiUrlController.dispose();
    _idController.dispose();
    super.dispose();
  }

  Future<void> _testApiConnection() async {
    setState(() {
      _isLoading = true;
    });

    final apiUrl = _apiUrlController.text.trim();
    final id = _idController.text.trim();

    // Build the final URL
    final String finalUrl = id.isNotEmpty ? '$apiUrl/$id' : apiUrl;

    try {
      final response = await http.get(Uri.parse(finalUrl));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('API connection successful!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('API error: Status code ${response.statusCode}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate QR Code'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter API Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _apiUrlController,
              decoration: InputDecoration(
                labelText: 'API URL',
                hintText: 'https://jsonplaceholder.typicode.com/posts',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: 'Resource ID (optional)',
                hintText: 'Enter a number like 1, 2, 3, etc.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.numbers),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: _isLoading ? null : _testApiConnection,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.network_check),
                    label: const Text('Test Connection'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: _isLoading
                        ? null
                        : () {
                            final apiUrl = _apiUrlController.text.trim();

                            if (apiUrl.isNotEmpty) {
                              setState(() {
                                final id = _idController.text.trim();
                                // Create a JSON object with the API details
                                final Map<String, String> data = {
                                  'apiUrl': apiUrl,
                                  if (id.isNotEmpty) 'id': id,
                                };

                                // Convert to JSON string
                                qrData = jsonEncode(data);
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter an API URL'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                    icon: const Icon(Icons.qr_code),
                    label: const Text('Generate QR'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            if (qrData.isNotEmpty) ...[
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Text(
                        'QR Code Generated',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: QrImageView(
                          data: qrData,
                          version: QrVersions.auto,
                          size: 240.0,
                          backgroundColor: Colors.white,
                          errorStateBuilder: (context, error) {
                            return const Center(
                              child: Text(
                                'Error generating QR code',
                                style: TextStyle(color: Colors.red),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'QR Code Information:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            SelectableText(
                              qrData,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Scan this QR code with another device to fetch data from the API',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({Key? key}) : super(key: key);

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isScanning = true;

  // For handling platform-specific issues
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      if (_isScanning && scanData.code != null) {
        setState(() {
          _isScanning = false;
        });
        controller.pauseCamera();
        _processQrCode(scanData.code!);
      }
    });
  }

  Future<void> _processQrCode(String code) async {
    try {
      // Parse the QR code data
      final Map<String, dynamic> qrData = jsonDecode(code);
      final String apiUrl = qrData['apiUrl'];
      final String? id = qrData['id'];

      // Build the final URL
      final String finalUrl =
          id != null && id.isNotEmpty ? '$apiUrl/$id' : apiUrl;

      // Show loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Fetching data from API...'),
              ],
            ),
          ),
        );
      }

      // Make API call
      final response = await http.get(Uri.parse(finalUrl));

      // Close loading dialog if context is still mounted
      if (mounted) {
        Navigator.pop(context);
      }

      if (response.statusCode == 200) {
        // Navigate to results page with the API response if context is still mounted
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResultsPage(
                apiUrl: finalUrl,
                apiResponse: response.body,
              ),
            ),
          );
        }
      } else {
        _showErrorDialog('API Error', 'Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Close loading dialog if open and context is still mounted
      if (mounted) {
        Navigator.pop(context);
      }
      _showErrorDialog('Error', e.toString());
    }
  }

  void _showErrorDialog(String title, String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _isScanning = true;
                });
                controller?.resumeCamera();
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () async {
              await controller?.toggleFlash();
              setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () async {
              await controller?.flipCamera();
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.blue,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Scan a QR code to fetch API data',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Position the QR code within the frame',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ResultsPage extends StatelessWidget {
  final String apiUrl;
  final String apiResponse;

  const ResultsPage({
    Key? key,
    required this.apiUrl,
    required this.apiResponse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Try to parse and format JSON for better display
    String formattedResponse = apiResponse;
    dynamic parsedJson;
    bool isValidJson = true;

    try {
      // Parse JSON and then format it with indentation
      parsedJson = jsonDecode(apiResponse);
      formattedResponse =
          const JsonEncoder.withIndent('  ').convert(parsedJson);
    } catch (e) {
      // If not valid JSON, keep original
      isValidJson = false;
    }

    // Determine if we're dealing with a list or single object
    final bool isList = isValidJson && parsedJson is List;
    final int itemCount = isList ? parsedJson.length : 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('API Response'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              // Navigate back to home, clearing the stack
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              margin: EdgeInsets.zero,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'API Request Details',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'URL: $apiUrl',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Method: GET',
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (isValidJson) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Response Type: ${isList ? "List" : "Object"}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      if (isList) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Items: $itemCount',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Response Data:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (isValidJson && isList && itemCount > 0)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: itemCount > 10
                    ? 10
                    : itemCount, // Limit to 10 items for performance
                itemBuilder: (context, index) {
                  final item = parsedJson[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item['id'] != null) ...[
                            Text(
                              'ID: ${item['id']}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                          ],
                          if (item['title'] != null) ...[
                            Text(
                              'Title: ${item['title']}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                          ],
                          if (item['body'] != null) ...[
                            Text(
                              'Body: ${item['body']}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  formattedResponse,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            if (isValidJson && isList && itemCount > 10) ...[
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Showing 10 of $itemCount items',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            ],
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RawResponsePage(
                      apiUrl: apiUrl,
                      apiResponse: formattedResponse,
                    ),
                  ),
                );
              },
              child: const Text('View Raw Response'),
            ),
          ],
        ),
      ),
    );
  }
}

class RawResponsePage extends StatelessWidget {
  final String apiUrl;
  final String apiResponse;

  const RawResponsePage({
    Key? key,
    required this.apiUrl,
    required this.apiResponse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Raw Response'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'API URL: $apiUrl',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    apiResponse,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
