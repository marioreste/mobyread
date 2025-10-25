import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class IsbnScannerScreen extends StatefulWidget {
  const IsbnScannerScreen({super.key});

  @override
  State<IsbnScannerScreen> createState() => _IsbnScannerScreenState();
}

class _IsbnScannerScreenState extends State<IsbnScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _processing = false;
  bool _torchOn = false;

  bool _looksLikeIsbn(String code) {
    final digits = code.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length == 13 || digits.length == 10;
  }

  Future<void> _handleCode(String code) async {
    if (_processing) return;
    _processing = true;
    await _controller.stop();

    final isIsbn = _looksLikeIsbn(code);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isIsbn ? 'ISBN rilevato' : 'Codice rilevato'),
          content: SelectableText(code),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                Navigator.of(context).pop();
              },
              child: const Text('Copia'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Chiudi'),
            ),
          ],
        );
      },
    );

    Navigator.of(context).pop(code);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner ISBN'),
        actions: [
          IconButton(
            icon: Icon(_torchOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () async {
              try {
                await _controller.toggleTorch();
                setState(() => _torchOn = !_torchOn);
              } catch (_) {
                // ignore toggle errors
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final barcodes = capture.barcodes;
              if (barcodes.isEmpty) return;
              final raw = barcodes.first.rawValue;
              if (raw == null) return;
              _handleCode(raw);
            },
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 18),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
              child: const Text('Inquadra il codice a barre (EAN/ISBN)', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}