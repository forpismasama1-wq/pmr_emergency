import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ConnectionPage(),
    );
  }
}

class ConnectionPage extends StatefulWidget {
  const ConnectionPage({super.key});

  @override
  State<ConnectionPage> createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> {
  String hasil = 'Tekan TES KONEKSI.';
  bool loading = false;

  Future<void> tesKoneksi() async {
    setState(() {
      loading = true;
      hasil = 'Menghubungi server...';
    });

    try {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 15);

      final request = await client.getUrl(
        Uri.parse('$supabaseUrl/auth/v1/health'),
      );

      request.headers.set('apikey', supabasePublishableKey);

      final response = await request.close()
          .timeout(const Duration(seconds: 20));

      final body = await response
          .transform(const SystemEncoding().decoder)
          .join();

      client.close();

      setState(() {
        hasil = 'BERHASIL TERHUBUNG!\nHTTP ${response.statusCode}\n$body';
      });
    } catch (e) {
      setState(() {
        hasil = 'GAGAL TERHUBUNG:\n$e';
      });
    }

    setState(() => loading = false);
  }

  Future<void> daftar() async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabasePublishableKey,
      );
      setState(() => hasil = 'Supabase siap digunakan.');
    } catch (e) {
      setState(() => hasil = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PMR EMERGENCY'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.health_and_safety,
                color: Colors.red, size: 70),
            const Text('TES KONEKSI SUPABASE',
                style: TextStyle(fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : tesKoneksi,
                child: Text(loading ? 'MEMERIKSA...' : 'TES KONEKSI'),
              ),
            ),
            const SizedBox(height: 20),
            SelectableText(hasil),
          ],
        ),
      ),
    );
  }
}